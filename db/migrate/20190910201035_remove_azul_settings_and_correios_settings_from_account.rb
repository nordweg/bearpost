class RemoveAzulSettingsAndCorreiosSettingsFromAccount < ActiveRecord::Migration[5.2]
  def change
    remove_column :accounts, :azul_settings
    remove_column :accounts, :correios_settings
  end
end
