class CreateHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :histories do |t|
      t.integer  :shipment_id
      t.integer  :user_id
      t.string   :changed_by
      t.string   :description
      t.string   :category

      t.timestamps
    end
  end
end
