class AddUserIdToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :user_id, :integer
  end
end
