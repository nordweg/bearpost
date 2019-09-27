class AddBearpostStatusAndCarrierStatusCodeToHistory < ActiveRecord::Migration[5.2]
  def change
    add_column :histories, :bearpost_status, :string
    add_column :histories, :carrier_status_code, :string
  end
end
