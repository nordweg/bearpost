require 'rails_helper'

RSpec.describe "shipments/index", type: :view do
  before(:each) do
    assign(:shipments, [
      Shipment.create!(
        :shipment_number => "Shipment Number"
      ),
      Shipment.create!(
        :shipment_number => "Shipment Number"
      )
    ])
  end

  it "renders a list of shipments" do
    render
    assert_select "tr>td", :text => "Shipment Number".to_s, :count => 2
  end
end
