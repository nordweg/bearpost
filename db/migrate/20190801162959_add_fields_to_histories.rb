class AddFieldsToHistories < ActiveRecord::Migration[5.2]
  def change
    add_column :histories, :date, :datetime
    add_column :histories, :city, :string
    add_column :histories, :state, :string
  end
end
