class Shipment < ApplicationRecord
  # validates_uniqueness_of :shipment_number, scope: :order_number
  # validates_presence_of   :invoice_series
  # validates_presence_of   :invoice_number
  # If we want unique invoice numbers in a series
  # validates_uniqueness_of :invoice_number, scope: :invoice_series

  validates_uniqueness_of :shipment_number, scope: :user_id

  scope :ready, -> { where(status: 'pronto') }
  # criado, pronto para envio, enviado

  has_many    :packages, -> { order "created_at" }
  belongs_to  :account, optional: true
  belongs_to  :user, optional: true

  def shipped?
    shipped_at.present?
  end

  def recipient_full_name
    "#{recipient_first_name} #{recipient_last_name}"
  end
end
