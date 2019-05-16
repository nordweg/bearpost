class CreateReverseShipments < ActiveRecord::Migration[5.1]
  def change
    create_table :reverse_shipments do |t|
      t.string :authorization_code
      t.string :authorization_code_expiration_date
      t.timestamps
    end
  end
end
