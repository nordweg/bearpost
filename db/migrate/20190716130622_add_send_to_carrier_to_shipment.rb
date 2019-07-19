class AddSendToCarrierToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :sent_to_carrier, :boolean, default: false
  end
end
