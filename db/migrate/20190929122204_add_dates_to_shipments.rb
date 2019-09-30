
class AddDatesToShipments < ActiveRecord::Migration[5.2]
  def change
    change_table :shipments do |t|
      t.datetime :approved_at

      t.integer :handling_days_planned
      t.integer :handling_days_used
      t.integer :handling_days_delayed
      t.datetime :shipping_due_at

      t.integer :carrier_delivery_days_planned
      t.integer :carrier_delivery_days_used
      t.integer :carrier_delivery_days_delayed
      t.datetime :carrier_delivery_due_at

      t.integer :client_delivery_days_planned
      t.integer :client_delivery_days_used
      t.integer :client_delivery_days_delayed
      t.datetime :client_delivery_due_at
    end

  end
end
