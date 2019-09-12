class CreateCarrierSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :carrier_settings do |t|
      t.integer  :account_id
      t.string   :carrier_class
      t.jsonb    :settings, default: {}
      t.timestamps
    end
  end
end
