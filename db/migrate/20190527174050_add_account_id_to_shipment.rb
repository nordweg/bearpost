class AddAccountIdToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :account_id, :integer
  end
end
