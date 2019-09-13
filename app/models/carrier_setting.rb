class CarrierSetting < ApplicationRecord
  belongs_to :account
  def self.carrier(carrier_class)
    self.where(carrier_class: carrier_class.to_s).first
  end
end
