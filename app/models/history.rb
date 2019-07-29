class History < ApplicationRecord
  default_scope { order(created_at: :asc) }
  belongs_to :shipment
  belongs_to :user, optional: true, default: -> { Current.user }
end
