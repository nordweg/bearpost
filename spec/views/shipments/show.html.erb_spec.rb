require 'rails_helper'

RSpec.describe "shipments/show", type: :view do
  before(:each) do
    @shipment = assign(:shipment, Shipment.create!(
      :shipment_number => "R123"
    ))
  end

  it "Renders newly created shipment attributes" do
    render
    expect(rendered).to match(/R123/)
  end
end
