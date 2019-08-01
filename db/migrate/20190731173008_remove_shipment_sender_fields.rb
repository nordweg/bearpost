class RemoveShipmentSenderFields < ActiveRecord::Migration[5.2]
  def change
    remove_column :shipments, :sender_first_name, :string
    remove_column :shipments, :sender_last_name,  :string
    remove_column :shipments, :sender_email,  :string
    remove_column :shipments, :sender_phone,  :string
    remove_column :shipments, :sender_cpf,  :string
    remove_column :shipments, :sender_street,  :string
    remove_column :shipments, :sender_number,  :string
    remove_column :shipments, :sender_complement,  :string
    remove_column :shipments, :sender_neighborhood,  :string
    remove_column :shipments, :sender_zip,  :string
    remove_column :shipments, :sender_city,  :string
    remove_column :shipments, :sender_city_code,  :string
    remove_column :shipments, :sender_state,  :string
    remove_column :shipments, :sender_country,  :string
  end
end
