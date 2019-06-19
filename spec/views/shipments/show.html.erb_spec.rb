require 'rails_helper'

RSpec.describe "shipments/show", type: :view do
  before(:each) do
    @shipment = assign(:shipment, Shipment.create!(
      :invoice_number => "12345"
    ))
  end

  it "Renders newly created shipment attributes" do
    render
    expect(rendered).to match(/12345/)
  end
end
