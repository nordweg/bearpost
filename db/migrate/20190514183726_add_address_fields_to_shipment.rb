class AddAddressFieldsToShipment < ActiveRecord::Migration[5.1]
  def change
    # Sender address fields
    add_column :shipments, :sender_first_name, :string
    add_column :shipments, :sender_last_name,  :string
    add_column :shipments, :sender_email,      :string
    add_column :shipments, :sender_phone,      :string
    add_column :shipments, :sender_cpf,        :string
    add_column :shipments, :sender_street,     :string
    add_column :shipments, :sender_number,     :string
    add_column :shipments, :sender_complement, :string
    add_column :shipments, :sender_neighborhood,  :string
    add_column :shipments, :sender_cep,           :string
    add_column :shipments, :sender_city,          :string
    add_column :shipments, :sender_city_code,     :string
    add_column :shipments, :sender_state,         :string

    # Recipient address fields
    add_column :shipments, :recipient_first_name, :string
    add_column :shipments, :recipient_last_name,  :string
    add_column :shipments, :recipient_email,  :string
    add_column :shipments, :recipient_phone,  :string
    add_column :shipments, :recipient_cpf,  :string
    add_column :shipments, :recipient_street,  :string
    add_column :shipments, :recipient_number,  :string
    add_column :shipments, :recipient_complement,  :string
    add_column :shipments, :recipient_neighborhood,  :string
    add_column :shipments, :recipient_cep,  :string
    add_column :shipments, :recipient_city,  :string
    add_column :shipments, :recipient_city_code,  :string
    add_column :shipments, :recipient_state,  :string
  end
end
