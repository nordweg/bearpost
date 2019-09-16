class Shipment < ApplicationRecord
  validates_uniqueness_of :shipment_number
  validates_presence_of :carrier_class

  scope :ready_to_ship, -> { where(status: 'ready', sent_to_carrier:false) }
  scope :shipped,       -> { where(status: 'shipped') }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  belongs_to  :company
  accepts_nested_attributes_for :packages

  after_create :create_package
  before_save  :update_invoice_number
  after_update :save_status_change_to_history
  after_create :first_history

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
        before = I18n.t saved_changes["status"][0]
        after  = I18n.t saved_changes["status"][1]
        histories.create(
          user: Current.user,
          description: "Status alterado de #{before} para #{after}",
          category:'status',
          date: DateTime.now,
        )
    end
  end

  def get_tracking_number
    begin
      carrier = carrier.new(carrier_settings)
      carrier.authenticate! # REFACTOR > WHY DO WE NEED TO AUTHENTICATE FROM HERE? WOULDN'T IT BE BETTER TO INITIALIZE THE CARRIER AND JUST ASK FOR THE TRACKING CODE?
      tracking_number = carrier.get_tracking_number(@shipment)
      flash[:success] = 'Rastreio atualizado'
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to @shipment
  end

  def sent_to_carrier! # REFACTOR > Not to easy to understand what this is doing
    update(sent_to_carrier:true)
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

  def save_delivery_updates()
    delivery_updates = get_delivery_updates
    delivery_updates.each do |delivery_update|
      self.histories.create(
        description: delivery_update[:description],
        date: delivery_update[:date],
        changed_by: carrier.name,
        category: 'carrier',
      )
    end
    current_status = self.histories.recent_first.first[:"bearpost_status"]
    self.update(status: current_status)
  end

  def get_delivery_updates
    carrier.new(carrier_settings).get_delivery_updates(self)
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
