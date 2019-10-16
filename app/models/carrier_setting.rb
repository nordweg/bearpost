class CarrierSetting < ApplicationRecord
  belongs_to :account
  def self.carrier(carrier_class)
    self.where(carrier_class: carrier_class.to_s).first
  end

  def self.get_settings_from_shipment(shipment)
    self.find_by(account_id: shipment.account_id, carrier_class: shipment.carrier_class)
  end

end
