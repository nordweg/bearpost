class AddTrackingNumberToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :tracking_number, :string
  end
end
