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
  after_update :save_history
  after_create :first_history

  def carrier_setting
    CarrierSetting.find_by(account_id:account_id,carrier_class:carrier_class)
  end

  def first_history
    histories.create(
      user: Current.user,
      description: "Pedido criado",
      category:'status',
      date: DateTime.now,
    )
  end

  def save_history
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

  def sent_to_carrier!
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

  def full_name
    "#{first_name} #{last_name}"
  end

  def tracking_url
    carrier.tracking_url.gsub("{tracking}","#{tracking_number}")
  end

  def carrier
    Object.const_get carrier_class
  end

  def as_json(*)
    super.except("updated_at","invoice_xml").tap do |hash|
      hash["synced_with_carrier"] = sent_to_carrier ? 'true' : 'false'
      hash["carrier"] = carrier.name
    end
  end
end
