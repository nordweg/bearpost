class Package < ApplicationRecord
  belongs_to :shipment, optional: true
  validates_presence_of :weight, :on => :create, :message => "não pode ficar em branco"
end
