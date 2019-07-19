class AddTokenToCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :token, :string
    add_index  :companies, :token
  end
end
