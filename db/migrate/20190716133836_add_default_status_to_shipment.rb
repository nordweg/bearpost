class AddDefaultStatusToShipment < ActiveRecord::Migration[5.1]
  def change
    change_column :shipments, :status, :string, default: 'pending'
  end
end
