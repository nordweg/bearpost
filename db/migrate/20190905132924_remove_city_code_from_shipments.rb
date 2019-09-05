class RemoveCityCodeFromShipments < ActiveRecord::Migration[5.2]
  def change
    remove_column :shipments, :city_code
  end
end
