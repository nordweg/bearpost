class ChangeShipmentCepToZip < ActiveRecord::Migration[5.1]
  def change
    rename_column :shipments, :recipient_cep, :recipient_zip
    rename_column :shipments, :sender_cep, :sender_zip
  end
end
