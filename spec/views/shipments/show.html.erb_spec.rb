require 'rails_helper'

RSpec.describe "shipments/show", type: :view do
  before(:each) do
    @shipment = assign(:shipment, Shipment.create!(
      :shipment_number => "Shipment Number"
    ))
  end

  it "Renders newly created shipment attributes" do
    render
    expect(rendered).to match(/Shipment Number/)
  end
end
