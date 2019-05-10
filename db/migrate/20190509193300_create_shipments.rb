class CreateShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :shipments do |t|
      t.timedate :shipped_at
      t.string :status
      t.string :carrier_name
      
      t.timestamps
    end
  end
end
