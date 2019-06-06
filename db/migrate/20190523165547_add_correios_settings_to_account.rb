class AddCorreiosSettingsToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :correios_settings, :jsonb, default: {}
  end
end
