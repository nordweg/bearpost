class AddFieldsToAccount < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :cnpj, :string
    add_column :accounts, :razao_social, :string
    add_column :accounts, :inscricao_estadual, :string
    add_column :accounts, :phone, :string
    add_column :accounts, :email, :string
    add_column :accounts, :street, :string
    add_column :accounts, :number, :string
    add_column :accounts, :complement, :string
    add_column :accounts, :neighborhood, :string
    add_column :accounts, :city, :string
    add_column :accounts, :zip, :string
    add_column :accounts, :state, :string
    add_column :accounts, :country, :string
  end
end
