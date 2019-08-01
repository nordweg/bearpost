class RemoveShipmentRecipientPrefix < ActiveRecord::Migration[5.2]
  def change
    rename_column :shipments, :recipient_first_name, :first_name
    rename_column :shipments, :recipient_last_name, :last_name
    rename_column :shipments, :recipient_email, :email
    rename_column :shipments, :recipient_phone, :phone
    rename_column :shipments, :recipient_cpf, :cpf
    rename_column :shipments, :recipient_street, :street
    rename_column :shipments, :recipient_number, :number
    rename_column :shipments, :recipient_complement, :complement
    rename_column :shipments, :recipient_neighborhood, :neighborhood
    rename_column :shipments, :recipient_zip, :zip
    rename_column :shipments, :recipient_city, :city
    rename_column :shipments, :recipient_city_code, :city_code
    rename_column :shipments, :recipient_state, :state
    rename_column :shipments, :recipient_country, :country
  end
end
