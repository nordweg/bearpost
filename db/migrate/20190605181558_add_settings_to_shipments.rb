class AddSettingsToShipments < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :settings, :jsonb, default: {}
  end
end
