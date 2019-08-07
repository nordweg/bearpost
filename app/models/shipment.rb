class Shipment < ApplicationRecord
  # validates_uniqueness_of :shipment_number, scope: :order_number
  # validates_presence_of   :invoice_series
  # validates_presence_of   :invoice_number
  # If we want unique invoice numbers in a series
  # validates_uniqueness_of :invoice_number, scope: :invoice_series

  validates_uniqueness_of :shipment_number, scope: :company_id

  scope :ready_to_ship, -> { where(status: 'ready', sent_to_carrier:false) }
  scope :shipped,       -> { where(status: 'shipped' }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  belongs_to  :company
  accepts_nested_attributes_for :packages

  after_create :create_package
  before_save  :update_invoice_number
  after_update :save_history

  def save_history
    if saved_changes.include?("status")
        before = I18n.t saved_changes["status"][0]
        after  = I18n.t saved_changes["status"][1]

        histories.create(
          user: Current.user,
          description: "Status alterado de #{before} para #{after}",
          category:'status'
        )
    end
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
    "Carrier::#{carrier_id.titleize}".constantize rescue nil
  end

  def as_json(*)
    super.except("updated_at","invoice_xml").tap do |hash|
      hash["synced_with_carrier"] = sent_to_carrier ? 'true' : 'false'
    end
  end
end
