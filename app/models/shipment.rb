class Shipment < ApplicationRecord
  validates_uniqueness_of :shipment_number
  validates_presence_of :carrier_class

  scope :ready_to_ship, -> { where(status: 'Ready for shipping', sent_to_carrier: false) }
  scope :shipped,       -> { where(status: 'On the way') }
  scope :shipped_but_not_delivered, -> { where(status: ["On the way", "Out for delivery", "Problematic", "Waiting for pickup"]) }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  accepts_nested_attributes_for :packages

  after_create :create_package
  before_save  :update_invoice_number
  after_update :save_status_change_to_history, if: :saved_change_to_status?
  after_update :update_dates, if: :saved_change_to_status?
  after_create :first_history
  before_save :update_planning_dates

  STATUSES = ["Pending", "Ready for shipping", "On the way", "Waiting for pickup", "Out for delivery", "Delivered", "Problematic", "Returned", "Cancelled"]

  def self.statuses
    STATUSES
  end

  validates :status, inclusion: {in: STATUSES}
  validates_presence_of :shipment_number

  def carrier_settings
    CarrierSetting.get_settings_from_shipment(self)
  end

  def update_planning_dates # REFACTOR > better name and clean method code
    # self.approved_at = 1.business_days.before(self.shipped_at) # REFACTOR >> Receive this from API
    # self.handling_days_planned = 2 # REFACTOR >> Receive this from API
    # self.carrier_delivery_days_planned = 4 # REFACTOR >> Receive this from API
    self.client_delivery_days_planned = self.handling_days_planned + self.carrier_delivery_days_planned
    self.shipping_due_at = self.handling_days_planned.business_days.after(self.approved_at)

    if self.approved_at && self.shipped_at
      self.handling_days_used = self.approved_at.to_date.business_days_until(self.shipped_at.to_date) if self.approved_at && self.shipped_at
      self.handling_days_delayed = self.handling_days_used - self.handling_days_planned
    end

    if self.shipped_at
      self.carrier_delivery_due_at = self.carrier_delivery_days_planned.business_days.after(self.shipped_at)
    end

    if self.delivered_at
      self.carrier_delivery_days_used = self.shipped_at.to_date.business_days_until(self.delivered_at.to_date) if self.shipped_at && self.delivered_at
      self.carrier_delivery_days_delayed = self.carrier_delivery_days_used - self.carrier_delivery_days_planned
    end

    self.client_delivery_due_at = self.client_delivery_days_planned.business_days.after(self.approved_at)

    if self.delivered_at
      self.client_delivery_days_used = self.approved_at.to_date.business_days_until(self.delivered_at.to_date) if self.approved_at && self.delivered_at
      self.client_delivery_days_delayed = self.client_delivery_days_used - self.client_delivery_days_planned
    end

    if self.shipping_due_at
      if (self.shipped_at.to_date || Date.today).to_date > self.shipping_due_at.to_date
        self.handling_late = true
      end
    else
      self.handling_late = false
    end

    if self.carrier_delivery_due_at
      if (self.delivered_at || Date.today).to_date > self.carrier_delivery_due_at.to_date
        self.carrier_delivery_late = true
      else
        self.carrier_delivery_late = false
      end
    else
      self.carrier_delivery_late = false
    end

    if self.client_delivery_due_at
      if (self.delivered_at || Date.today).to_date > self.client_delivery_due_at.to_date
        self.client_delivery_late = true
      end
    else
      self.client_delivery_late = false
    end
  end

  def first_history # REFACTOR > Rename this
    histories.create(
      user: Current.user,
      description: "Pedido criado",
      category:'status',
      date: DateTime.now,
    )
  end

  def save_status_change_to_history
    histories.create(
      user: Current.user,
      description: "Status alterado de #{I18n.t saved_changes["status"][0]} para #{I18n.t saved_changes["status"][1]}",
      category:'status',
      date: DateTime.now,
      changed_by: Current.connected
    )
  end

  def update_dates # Refactor > Better name (not to confuse with update_planning_dates)
    case status
      when "Ready for shipping"  then touch(:ready_for_shipping_at)
      when "On the way"          then touch(:shipped_at)
      when "Delivered"           then update(delivered_at: find_delivery_time)
    end
  end

  def find_delivery_time
    histories.find_by(bearpost_status:"Delivered").date
  end

  def get_tracking_number
    return tracking_number if tracking_number.present?
    carrier = self.carrier.new(carrier_settings)
    tracking_number = carrier.get_tracking_number(self)
    self.update(tracking_number: tracking_number)
    self.tracking_number
  end

  def sent_to_carrier! # REFACTOR > Not to easy to understand what this is doing
    update(sent_to_carrier: true)
    histories.create(
      user: Current.user,
      description: "Pedido enviado para a transportadora #{carrier.name}",
      category:'status',
      date: DateTime.now,
    )
  end

  def update_invoice_number
    if changes.include?("invoice_xml")
      doc = Nokogiri::XML(invoice_xml)
      self.invoice_number = doc.at_css('nNF').content
      self.invoice_series = doc.at_css('serie').content
    end
  end

  def create_package
    if packages.empty?
      packages.create()
    end
  end

  def shipped?
    shipped_at.present?
  end

  def full_name # REFACTOR > Receipient full name?
    "#{first_name} #{last_name}"
  end

  def tracking_url
    carrier.tracking_url.gsub("{tracking}","#{tracking_number}")
  end

  def carrier
    Object.const_get(carrier_class)
  end

  def as_json(*)
    super.except("updated_at","invoice_xml").tap do |hash|
      hash["synced_with_carrier"] = sent_to_carrier ? 'true' : 'false'
      hash["carrier"] = carrier.name
    end
  end

  def self.filter(params)
    if params[:search].present?
      shipments = self.where(
        "CONCAT(first_name, ' ' ,last_name) ILIKE :search
        OR regexp_replace(cpf, '\\D', '', 'g') ILIKE regexp_replace(:search, '\\D', '', 'g')
        OR order_number ILIKE :search
        OR shipment_number ILIKE :search
        OR city ILIKE :search",
        search: "%#{params[:search]}%"
      )
    else
      shipments = self.all
    end
    shipments = shipments.where(status:params[:status]) if params[:status].present?
    shipments = shipments.where(carrier_class: params[:carrier]) if params[:carrier].present?
    shipments = shipments.where(params[:late] => true) if params[:late].present?
    if params[:date_range].present?
      start_date = DateTime.parse(params[:date_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:date_range][13..-1]).end_of_day
      shipments = shipments.where("shipped_at > ? AND shipped_at < ?", start_date, end_date)
    end
    shipments
  end

end
