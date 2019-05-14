class AddInvoiceNumberAndSeriesToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :invoice_series, :integer
    add_column :shipments, :invoice_number, :integer
  end
end
