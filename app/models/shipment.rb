class Shipment < ApplicationRecord
  # validates_uniqueness_of :shipment_number, scope: :order_number
  # validates_presence_of   :invoice_series
  # validates_presence_of   :invoice_number
  # If we want unique invoice numbers in a series
  # validates_uniqueness_of :invoice_number, scope: :invoice_series

  validates_uniqueness_of :shipment_number, scope: :company_id

  scope :ready, -> { where(status: 'ready') }

  has_many    :packages
  has_many    :histories
  belongs_to  :account, optional: true
  belongs_to  :company
  accepts_nested_attributes_for :packages

  after_create :create_package
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

  def create_package
    if packages.empty?
      packages.create()
    end
  end

  def shipped?
    shipped_at.present?
  end

  def recipient_full_name
    "#{recipient_first_name} #{recipient_last_name}"
  end

  def requirements_missing
    errors = []
    errors << "Shipment: Carrier is required" if carrier_name.blank?
    errors << "Shipment: Shipping method is required" if shipping_method.blank?
    errors
  end

  def carrier
    "Carrier::#{carrier_name.titleize}".constantize rescue nil
  end
end
