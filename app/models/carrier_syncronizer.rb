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
    shipments = Shipment.shipped.not_delivered
    CarrierSyncronizer.update_shipments_delivery_status(shipments)
  end

  def self.update_shipments_delivery_status(shipments)
    errors = []
    shipments_updated = 0
    shipments.each do |shipment|
      begin
        update_shipment_delivery_status(shipment)
        shipments_updated += 1
      rescue Exception => e
        errors << "Shipment #{shipment.id} - #{shipment.carrier}: #{e.message}"
        next
      end
    end
    puts "STATUS UPDATE RESULTS: #{shipments_updated} shipments updated, #{errors.size} errors"
    puts errors
  end

  def self.update_shipment_delivery_status(shipment)
    delivery_updates = get_delivery_updates(shipment)
    create_histories(shipment,delivery_updates)
    update_current_status(shipment,delivery_updates)
  end

  def self.get_delivery_updates(shipment)
    shipment.get_tracking_number
    delivery_updates = shipment.carrier.new(shipment.carrier_settings).get_delivery_updates(shipment)
    unknown_delivery_updates = delivery_updates.select { |delivery_update| delivery_update[:bearpost_status] == nil }
    unknown_delivery_updates.each do |delivery_update|
      puts "FOLLOW UP: Shipment #{shipment.id} - The carrier #{shipment.carrier.name} has an unknown status: #{delivery_update[:status_code]}"
    end
    delivery_updates
  end

  def self.create_histories(shipment,delivery_updates)
    delivery_updates.each do |delivery_update|
      history = History.new(
        shipment: shipment,
        description: delivery_update[:description],
        date: delivery_update[:date],
        changed_by: shipment.carrier.name,
        bearpost_status: delivery_update[:bearpost_status],
        carrier_status_code: delivery_update[:status_code],
        category: 'carrier',
      )
      history.save if history.valid?
    end
  end

  def self.update_current_status(shipment, delivery_updates)
    delivery_updates.sort_by! { |delivery_update| delivery_update[:date] }
    current_status = delivery_updates.last[:bearpost_status]
    delivery_date  = nil
    delivery_updates.each do |delivery_update|
      if delivery_update[:bearpost_status] == "Delivered"
        current_status = "Delivered"
        delivery_date  = delivery_update[:date]
      end
    end
    shipment.update(status: current_status, delivered_at: delivery_date)
  end

end
