class RemoveCarriers < ActiveRecord::Migration[5.1]
  def change
    drop_table :carriers
  end
end
