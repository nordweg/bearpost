class AddLastSynchedAtToShipments < ActiveRecord::Migration[5.2]
  def change
    add_column :shipments, :last_synched_at, :datetime
  end
end
