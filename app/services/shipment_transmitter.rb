class ShipmentTransmitter
  def self.transmit(shipments)
    transmit_results = {}
    grouped_shipments = group_shipments_by_account_and_carrier(shipments)
    grouped_shipments.each do |account_name, carriers_hash|
      carriers_hash.each do |carrier_name, shipments_array|
        transmit_results[account_name] ||= {}
        begin
          carrier_class = Carriers.find(carrier_name)
          carrier_setting = Account.find_by(name:account_name).carrier_setting_for(carrier_class)
          carrier = carrier_class.new(carrier_setting)
          transmit_results[account_name][carrier_name] = carrier.transmit_shipments(shipments_array)
        rescue Exception => e
          transmit_results[account_name][carrier_name] = shipments_array.map { |shipment| {shipment: shipment, success: false, message: e.message} }
        end
      end
    end
    transmit_results
  end

  def self.group_shipments_by_account_and_carrier(shipments)
    grouped_shipments = {}
    shipments.each do |shipment|
      account = shipment.account.name
      carrier = shipment.carrier.name
      grouped_shipments[account] ||= {}
      grouped_shipments[account][carrier] ||= []
      grouped_shipments[account][carrier] << shipment
    end
    grouped_shipments
  end

  def self.transmit_all_ready_shipments
    shipments = Shipment.all.ready_to_ship.not_transmitted
    transmit(shipments)
  end
end
