require 'rails_helper'

RSpec.describe "packages/index", type: :view do
  before(:each) do
    assign(:packages, [
      Package.create!(
        :heigth => 2.5,
        :width => 3.5,
        :depth => 4.5,
        :weight => 5.5,
        :shipment => nil
      ),
      Package.create!(
        :heigth => 2.5,
        :width => 3.5,
        :depth => 4.5,
        :weight => 5.5,
        :shipment => nil
      )
    ])
  end

  it "renders a list of packages" do
    render
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => 4.5.to_s, :count => 2
    assert_select "tr>td", :text => 5.5.to_s, :count => 2
    assert_select "tr>td", :text => nil.to_s, :count => 2
  end
end
