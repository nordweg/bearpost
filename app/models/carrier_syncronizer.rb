class CarrierSyncronizer

  def self.sync(shipments)
    sync_results = []
    grouped_shipments = group_shipments_by_account_and_carrier(shipments)
    grouped_shipments.each do |account, carriers_hash|
      carriers_hash.each do |carrier, shipments_array|
        sync_result = {
          account: account,
          carrier: carrier,
          sync_result: carrier.sync_shipments(shipments_array)
        }
        sync_results << sync_result
      end
    end
    sync_results
  end

  def group_shipments_by_account_and_carrier(shipments)
    grouped_shipments = {}
    shipments.each do |shipment|
      account = shipment.account
      carrier = shipment.carrier_class
      grouped_shipments[account] ||= {}
      grouped_shipments[account][carrier] ||= []
      grouped_shipments[account][carrier] << shipment
    end
    grouped_shipments
  end

end
