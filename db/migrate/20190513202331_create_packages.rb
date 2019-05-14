class CreatePackages < ActiveRecord::Migration[5.1]
  def change
    create_table :packages do |t|
      t.integer  :shipment_id
      t.string   :tracking_number
      t.float    :heigth
      t.float    :width
      t.float    :depth
      t.float    :weight
      t.float    :items_value
      t.timestamps
    end
  end
end
