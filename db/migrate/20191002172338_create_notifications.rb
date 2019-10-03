class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.integer  :user_id
      t.string   :description
      t.string   :path
      t.string   :category
      t.boolean  :read, default: false

      t.timestamps
    end
  end
end
