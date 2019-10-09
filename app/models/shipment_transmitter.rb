class ShipmentTransmitter # REFACTOR > Make this simpler to understand
  def self.transmit(shipments)
    transmit_results = []
    grouped_shipments = group_shipments_by_account_and_carrier(shipments)
    grouped_shipments.each do |account, carriers_hash|
      carriers_hash.each do |carrier, shipments_array|
        begin
          transmit_result = {
            account: account,
            carrier: carrier,
            transmit_result: carrier.transmit_shipments(shipments_array)
          }
        rescue Exception => e
          transmit_result = {
            account: account,
            carrier: carrier,
            transmit_result: shipments_array.map { |shipment| {shipment: shipment, success: false, message: e.message} }
          }
        end
        transmit_results << sync_result
      end
    end
    sync_results
  end

  def self.group_shipments_by_account_and_carrier(shipments)
    grouped_shipments = {}
    shipments.each do |shipment|
      account = shipment.account
      carrier = shipment.carrier.new(shipment.carrier_settings)
      grouped_shipments[account] ||= {}
      grouped_shipments[account][carrier] ||= []
      grouped_shipments[account][carrier] << shipment
    end
    grouped_shipments
  end

  def self.transmit_all_ready_shipments
    shipments = Shipment.all.ready_to_ship
    sync(shipments)
  end
end
