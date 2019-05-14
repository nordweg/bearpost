class CreateShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :shipments do |t|
      t.string   :status
      t.datetime :shipped_at
      t.string   :shipment_number
      t.string   :order_number
      t.float    :cost
      t.string   :carrier_name
      t.timestamps
    end
  end
end
