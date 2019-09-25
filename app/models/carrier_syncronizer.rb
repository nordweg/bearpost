class CarrierSyncronizer

  def self.sync(shipments) # REFACTOR > Rename this so its clear if its sending shipment or synching delivery statuses
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

  def self.update_all_shipments_delivery_status
    shipments = Shipment.all.shipped_but_not_delivered
    CarrierSyncronizer.update_shipments_delivery_status(shipments)
  end

  def self.update_shipments_delivery_status(shipments)
    errors = []
    shipments_updated = 0
    shipments.each do |shipment|
      begin
        shipment.save_tracking_number
        shipment.save_delivery_updates
        shipments_updated += 1
      rescue Exception => e
        errors << "Shipment #{shipment.id} - #{shipment.carrier}: #{e.message}"
        next
      end
    end
    puts "STATUS UPDATE RESULTS #{Time.now}"
    puts "#{shipments_updated} SHIPMENTS UPDATED"
    puts "#{errors.size} ERRORS"
    puts errors
  end

end
