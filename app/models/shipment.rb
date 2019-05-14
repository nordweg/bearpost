class Shipment < ApplicationRecord
  validates_uniqueness_of :shipment_number, scope: :order_number
  validates_presence_of   :invoice_series
  validates_presence_of   :invoice_number
  validates_uniqueness_of :invoice_number, scope: :invoice_series

  def shipped?
    shipped_at.present?
  end
end
