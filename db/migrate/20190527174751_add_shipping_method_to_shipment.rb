class AddShippingMethodToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :shipping_method, :string
  end
end
