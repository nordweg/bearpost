class RenameSentToCarrierToTransmitted < ActiveRecord::Migration[5.2]
  def change
    rename_column :shipments, :sent_to_carrier, :transmitted_to_carrier
  end
end
