class Shipment < ApplicationRecord
  scope :ready_to_ship,               -> { where(status: 'Ready for shipping') }
  scope :shipped,                     -> { where(status: ["On the way", "Out for delivery", "Problematic", "Waiting for pickup", "Delivered"]) }
  scope :delivered,                   -> { where(status: 'Delivered') }
  scope :not_delivered,               -> { where.not(status: "Delivered") }
  scope :not_canceled,                -> { where.not(status: "Canceled") }
  scope :in_transit,                  -> { shipped.not_delivered } # see if not.delivered exists
  scope :not_transmitted,             -> { where(transmitted_to_carrier: false) }
  scope :handling_late,               -> { where(handling_late: true) }
  scope :carrier_delivery_late,       -> { where(carrier_delivery_late: true) }
  scope :client_delivery_late,        -> { where(client_delivery_late: true) }
  scope :late,                        -> { handling_late.or(carrier_delivery_late).or(client_delivery_late) }
  scope :problematic,                 -> { where(status: "Problematic") }
  scope :attention_required,          -> { in_transit.late.or(problematic) }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  accepts_nested_attributes_for :packages

  after_create :log_shipment_creation_on_histories
  after_create :create_package

  before_save  :get_invoice_number, if: :will_save_change_to_invoice_xml?
  before_save  :get_delivery_dates
  before_save  :get_status_dates, if: :will_save_change_to_status?
  before_save  :log_status_change, if: :will_save_change_to_status?, unless: :new_record?
  before_save  :log_transmittion_to_carrier, if: :will_save_change_to_transmitted_to_carrier?

  STATUSES = ["Pending", "Ready for shipping", "On the way", "Waiting for pickup", "Out for delivery", "Delivered", "Problematic", "Lost", "Returned", "Cancelled"]

  def self.statuses
    STATUSES
  end

  validates                 :status, inclusion: {in: STATUSES}
  validates_presence_of     :shipment_number
  validates_uniqueness_of   :shipment_number
  validates_presence_of     :carrier_class
  validates_inclusion_of    :shipping_method, in: ->(shipment) { shipment.available_shipping_methods }, if: :carrier_class?

  def available_shipping_methods
    return [] unless carrier_class.try(:constantize)
    carrier_class.constantize::SERVICES
  end

  def carrier_settings
    CarrierSetting.get_settings_from_shipment(self)
  end

  def log_shipment_creation_on_histories
    histories.create(
      user: Current.user,
      changed_by: Current.connected,
      description: "Pedido criado",
      category:"New",
      date: DateTime.now,
    )
  end

  def get_status_dates
    case status
    when "Ready for shipping"
      self.ready_for_shipping_at = DateTime.now unless ready_for_shipping_at
    when "On the way"
      self.shipped_at = DateTime.now unless shipped_at
    when "Delivered"
      self.delivered_at = DateTime.now unless delivered_at
    end
  end

  def get_delivery_dates
    return unless handling_days_planned.present? && carrier_delivery_days_planned.present?
    self.client_delivery_days_planned = handling_days_planned + carrier_delivery_days_planned

    return unless approved_at.present?
    self.shipping_due_at = handling_days_planned.business_days.after(approved_at)
    self.client_delivery_due_at = client_delivery_days_planned.business_days.after(approved_at)
    self.handling_late = (shipped_at || Date.today).to_date > shipping_due_at.to_date
    self.client_delivery_late = (delivered_at || Date.today).to_date > client_delivery_due_at.to_date

    return unless shipped_at.present?
    self.handling_days_used = approved_at.to_date.business_days_until(shipped_at.to_date)
    self.handling_days_delayed = handling_days_used - handling_days_planned
    self.carrier_delivery_due_at = carrier_delivery_days_planned.business_days.after(shipped_at)
    self.carrier_delivery_late = (delivered_at || Date.today).to_date > carrier_delivery_due_at.to_date

    return unless delivered_at.present?
    self.carrier_delivery_days_used = shipped_at.to_date.business_days_until(delivered_at.to_date)
    self.carrier_delivery_days_delayed = carrier_delivery_days_used - carrier_delivery_days_planned
    self.client_delivery_days_used = approved_at.to_date.business_days_until(delivered_at.to_date)
    self.client_delivery_days_delayed = client_delivery_days_used - client_delivery_days_planned
  end

  def update_delivery_dates
    self.get_delivery_dates
    self.save
  end

  def log_status_change
    histories.create(
      user: Current.user,
      description: "Status alterado de #{I18n.t status_was} para #{I18n.t status}",
      bearpost_status: status,
      category: status,
      date: DateTime.now,
      changed_by: Current.connected
    )
  end

  def log_transmittion_to_carrier
    histories.create(
      user: Current.user,
      description: "Envio transmitido para a transportadora",
      category: "Transmission",
      date: DateTime.now,
      changed_by: Current.connected
    )
  end

  def get_tracking_number
    return tracking_number if tracking_number.present?
    tracking_number = carrier.get_tracking_number(self)
    self.update(tracking_number: tracking_number)
    self.tracking_number
  end

  def get_invoice_number
    doc = Nokogiri::XML(invoice_xml)
    self.invoice_number = doc.at_css('nNF').content
    self.invoice_series = doc.at_css('serie').content
  end

  def create_package
    if packages.empty?
      packages.create()
    end
  end

  def shipped?
    shipped_at.present?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def external_order_url
    external_order_url = Setting.find_by(key:"external_order_url")
    return self unless external_order_url
    external_order_url.value.sub('{tracking}',order_number)
  end

  def tracking_url
    carrier.class.tracking_url.gsub("{tracking}","#{tracking_number}")
  end

  def carrier
    Object.const_get(carrier_class).new(carrier_settings)
  end

  def as_json(*)
    super.except("updated_at","invoice_xml").tap do |hash|
      hash["transmitted"] = transmitted_to_carrier ? 'true' : 'false'
      hash["carrier"] = carrier.class.name
    end
  end

  def self.filter(params)
    if params[:search].present?
      shipments = self.where(
        "CONCAT(first_name, ' ' ,last_name) ILIKE :search
        OR regexp_replace(cpf, '\\D', '', 'g') ILIKE regexp_replace(:search, '\\D', '', 'g')
        OR order_number ILIKE :search
        OR shipment_number ILIKE :search
        OR state ILIKE :search
        OR zip ILIKE :search
        OR city ILIKE :search",
        search: "%#{params[:search]}%"
      )
    else
      shipments = self.all
    end
    shipments = shipments.where(status:params[:status]) if params[:status].present?
    if params[:carrier].present?
      carrier_class = Carriers.find(params[:carrier]).to_s
      shipments = shipments.where(carrier_class: carrier_class)
    end
    shipments = shipments.where(params[:late] => true) if params[:late].present?
    shipments = shipments.where(carrier_delivery_days_used: params[:carrier_delivery_days_used]) if params[:carrier_delivery_days_used].present?
    shipments = shipments.where(shipping_method: params[:shipping_method]) if params[:shipping_method].present?
    shipments = shipments.where(account_id: params[:account_id]) if params[:account_id].present?
    shipments = shipments.where(transmitted_to_carrier: params[:transmitted_to_carrier]) if params[:transmitted_to_carrier].present?
    shipments = shipments.where(state: params[:state]) if params[:state].present?
    if params[:shipped_at_range].present?
      start_date = DateTime.parse(params[:shipped_at_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:shipped_at_range][13..-1]).end_of_day
      shipments = shipments.where("shipped_at > ? AND shipped_at < ? OR shipped_at IS NULL", start_date, end_date)
    end
    if params[:created_at_range].present?
      start_date = DateTime.parse(params[:created_at_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:created_at_range][13..-1]).end_of_day
      shipments = shipments.where("created_at > ? AND created_at < ? OR created_at IS NULL", start_date, end_date)
    end
    if params[:delivered_at_range].present?
      start_date = DateTime.parse(params[:delivered_at_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:delivered_at_range][13..-1]).end_of_day
      shipments = shipments.where("delivered_at > ? AND delivered_at < ?", start_date, end_date)
    end
    shipments
  end

end
