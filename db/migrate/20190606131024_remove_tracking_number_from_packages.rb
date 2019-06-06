class RemoveTrackingNumberFromPackages < ActiveRecord::Migration[5.1]
  def change
    remove_column :packages, :tracking_number, :string
  end
end
