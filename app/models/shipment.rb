class Shipment < ApplicationRecord
  # validates_uniqueness_of :shipment_number, scope: :order_number
  # validates_presence_of   :invoice_series
  # validates_presence_of   :invoice_number
  # If we want unique invoice numbers in a series
  # validates_uniqueness_of :invoice_number, scope: :invoice_series

  has_many :packages

  def shipped?
    shipped_at.present?
  end

  def full_name
    "#{recipient_first_name} #{recipient_last_name}"
  end
end
