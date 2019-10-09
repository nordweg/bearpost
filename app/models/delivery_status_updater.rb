class DeliveryStatusUpdater
  def self.update(shipments)
    errors = []
    shipments_updated = 0
    shipments.each do |shipment|
      begin
        update_single_shipment(shipment)
        shipments_updated += 1
      rescue Exception => e
        errors << "Shipment #{shipment.id} - #{shipment.carrier}: #{e.message}"
        next
      end
    end
    puts "STATUS UPDATE RESULTS: #{shipments_updated} shipments updated, #{errors.size} errors"
    puts errors
  end

  def self.update_all_shipments
    shipments = Shipment.shipped.not_delivered
    update(shipments)
  end

  def self.update_single_shipment(shipment)
    raise "O envio #{shipment.number} não possui rastreio" unless shipment.tracking_number
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
