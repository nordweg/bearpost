class ShipmentTransmitter # REFACTOR > Make this simpler to understand
  def self.sync(shipments)
    sync_results = []
    grouped_shipments = group_shipments_by_account_and_carrier(shipments)
    grouped_shipments.each do |account, carriers_hash|
      carriers_hash.each do |carrier, shipments_array|
        begin
          sync_result = {
            account: account,
            carrier: carrier,
            sync_result: carrier.sync_shipments(shipments_array)
          }
        rescue Exception => e
          response = []
          shipments_array.each do |shipment|
            response << {
              shipment: shipment,
              success: shipment.sent_to_carrier,
              message: e.message
            }
          end
          sync_result = {
            account: account,
            carrier: carrier,
            sync_result: response
          }
        end
        sync_results << sync_result
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

  def self.sync_all_ready_shipments
    shipments = Shipment.all.ready_to_ship
    sync(shipments)
  end

end
