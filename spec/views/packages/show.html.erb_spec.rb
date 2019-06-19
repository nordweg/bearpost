require 'rails_helper'

RSpec.describe "packages/show", type: :view do
  before(:each) do
    @package = assign(:package, Package.create!(
      :heigth => 2.5,
      :width => 3.5,
      :depth => 4.5,
      :weight => 5.5,
      :shipment => nil
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4.5/)
    expect(rendered).to match(/5.5/)
    expect(rendered).to match(//)
  end
end
