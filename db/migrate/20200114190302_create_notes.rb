class CreateNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :notes do |t|
      t.string :description
      t.integer :shipment_id
      t.integer :user_id

      t.timestamps
    end
  end
end
