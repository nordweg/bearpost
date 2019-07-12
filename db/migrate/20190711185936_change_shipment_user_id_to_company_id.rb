class ChangeShipmentUserIdToCompanyId < ActiveRecord::Migration[5.1]
  def change
    rename_column :shipments, :user_id, :company_id
  end
end
