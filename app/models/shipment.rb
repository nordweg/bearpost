class Shipment < ApplicationRecord
  # validates_uniqueness_of :shipment_number, scope: :order_number
  # validates_presence_of   :invoice_series
  # validates_presence_of   :invoice_number
  # If we want unique invoice numbers in a series
  # validates_uniqueness_of :invoice_number, scope: :invoice_series

  validates_uniqueness_of :shipment_number, scope: :company_id

  scope :ready, -> { where(status: 'pronto') }
  # criado, pronto para envio, enviado

  has_many    :packages, -> { order "created_at" }
  belongs_to  :account, optional: true
  belongs_to  :company

  accepts_nested_attributes_for :packages

  after_save :track_changes

  def track_changes
    if saved_changes.include?("status")
        20.times do
          p "Status changed from #{saved_changes['status'][0]} to #{saved_changes['status'][1]}"
        end
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
    errors << "Shipment: Account is required" if account.blank?
    errors << "Shipment: Carrier is required" if carrier_name.blank?
    errors << "Shipment: Shipping method is required" if shipping_method.blank?
    errors << "Shipment: Shipping Number is required" if shipment_number.blank?
    errors << "Shipment: At least 1 package is required" if packages.blank?
    errors
  end

  def carrier
    "Carrier::#{carrier_name.titleize}".constantize rescue nil
  end
end
