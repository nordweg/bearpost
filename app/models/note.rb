class Note < ApplicationRecord
  belongs_to :shipment
  belongs_to :user
end
