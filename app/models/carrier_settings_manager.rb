class CarrierSettingsManager

  def self.get_carrier_settings_from_shipment(shipment) # REFACTOR > Should we put this under CarrierSetting?
    CarrierSetting.find_by(account_id: shipment.account_id, carrier_class: shipment.carrier.to_s)
  end

  def get_carrier_settings(account_id, carrier_class)
    CarrierSetting.find_by(account_id: account_id, carrier_class: carrier_class)
  end

end
