require 'rails_helper'

RSpec.describe "shipments/edit", type: :view do
  before(:each) do
    @shipment = assign(:shipment, Shipment.create!(
      :shipment_number => "MyString"
    ))
  end

  it "renders the edit shipment form" do
    render

    assert_select "form[action=?][method=?]", shipment_path(@shipment), "post" do

      assert_select "input[name=?]", "shipment[shipment_number]"
    end
  end
end
