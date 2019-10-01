class AddDeliveryStatsToShipment < ActiveRecord::Migration[5.2]
  def change
    change_table :shipments do |t|
      t.boolean :handling_late
      t.boolean :carrier_delivery_late
      t.boolean :client_delivery_late
    end
  end
end
