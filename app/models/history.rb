class History < ApplicationRecord
  belongs_to :shipment
  # belongs_to :user, optional: true, default: -> { Current.user }
  belongs_to :user, optional: true

  scope :recent_first,   -> { order(date: :desc) }
end
