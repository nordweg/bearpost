class AddInvoiceXmlToShipment < ActiveRecord::Migration[5.1]
  def change
    add_column :shipments, :invoice_xml, :xml
  end
end
