class ChangeCarrierIdToCarrierClass < ActiveRecord::Migration[5.2]
  def change
    rename_column :shipments, :carrier_id, :carrier_class
  end
end
