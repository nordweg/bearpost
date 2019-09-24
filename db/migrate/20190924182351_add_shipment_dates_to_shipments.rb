class AddShipmentDatesToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :ready_for_shipping_at, :datetime
    add_column :shipments, :delivered_at, :datetime
  end
end
