class RenameShipmentsCarrierNameToCarrierId < ActiveRecord::Migration[5.2]
  def change
    rename_column :shipments, :carrier_name, :carrier_id
  end
end
