require 'rails_helper'

RSpec.describe "packages/edit", type: :view do
  before(:each) do
    @package = assign(:package, Package.create!(
      :heigth => 1.5,
      :width => 1.5,
      :depth => 1.5,
      :weight => 1.5,
      :shipment => nil
    ))
  end

  it "renders the edit package form" do
    render

    assert_select "form[action=?][method=?]", package_path(@package), "post" do

      assert_select "input[name=?]", "package[heigth]"

      assert_select "input[name=?]", "package[width]"

      assert_select "input[name=?]", "package[depth]"

      assert_select "input[name=?]", "package[weight]"

      assert_select "input[name=?]", "package[shipment_id]"
    end
  end
end
