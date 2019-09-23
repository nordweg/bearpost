class Shipment < ApplicationRecord
  validates_uniqueness_of :shipment_number
  validates_presence_of :carrier_class

  scope :ready_to_ship, -> { where(status: 'Ready for shipping', sent_to_carrier: false) }
  scope :shipped,       -> { where(status: 'On the way') }
  scope :shipped_but_not_delivered, -> { where(status: ["On the way", "Out for delivery", "Problematic", "Waiting for pickup"]) }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  belongs_to  :company, optional: true
  accepts_nested_attributes_for :packages

  after_create :create_package
  before_save  :update_invoice_number
  after_update :save_status_change_to_history
  after_create :first_history

  STATUSES = ["Pending", "Ready for shipping", "On the way", "Waiting for pickup", "Out for delivery", "Delivered", "Problematic", "Returned", "Cancelled"]

  def self.statuses
    STATUSES
  end

  validates :status, inclusion: {in: STATUSES}

  def carrier_settings
    CarrierSetting.get_settings_from_shipment(self)
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
    if saved_changes.include?("status")
      histories.create(
        user: Current.user,
        description: "Status alterado de #{I18n.t saved_changes["status"][0]} para #{I18n.t saved_changes["status"][1]}",
        category:'status',
        date: DateTime.now,
        changed_by: Current.connected
      )
    end
  end

  def get_tracking_number
    return tracking_number if tracking_number.present?
    carrier = self.carrier.new(carrier_settings)
    tracking_number = carrier.get_tracking_number(self)
  end

  def save_tracking_number # REFACTOR > Change name to Update or join with get_tracking_number
    self.tracking_number = get_tracking_number
    if self.tracking_number_changed?
      self.update(tracking_number: tracking_number)
    end
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

  def get_delivery_updates # REFACTOR > Passar pro CarrierSyncronizer?
    delivery_updates = carrier.new(carrier_settings).get_delivery_updates(self)
    delivery_updates.sort_by {|delivery_update| delivery_update[:date]}
  end

  def save_delivery_updates # REFACTOR > Passar pro CarrierSyncronizer?
    delivery_updates = get_delivery_updates
    delivery_updates.each do |delivery_update|
      History.create(
        shipment: self,
        description: delivery_update[:description],
        date: delivery_update[:date],
        changed_by: carrier.name,
        category: 'carrier',
      )
    end
    # self.histories.create(
    #   description: "Sincronizou status de entrega com #{self.carrier.name}",
    #   date: Time.now,
    #   changed_by: "Bearpost",
    #   category: 'carrier',
    # )
    current_status = delivery_updates.last[:bearpost_status]
    self.update(status: current_status)
    # byebug
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
    shipments = shipments.where(carrier_class:params[:carrier]) if params[:carrier].present?
    if params[:date_range].present?
      start_date = DateTime.parse(params[:date_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:date_range][13..-1]).end_of_day
      shipments = shipments.where("created_at > ? AND created_at < ?", start_date, end_date)
    end
    shipments
  end

end
