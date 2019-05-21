class AddCountryToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :sender_country, :string
    add_column :shipments, :recipient_country, :string
  end
end
