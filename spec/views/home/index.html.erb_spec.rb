require 'rails_helper'
require 'capybara/rails'

RSpec.describe "home/index.html.erb", type: :view do
  it "Displays the app name" do
    visit "/"
    expect(page).to have_content 'BearPost'
  end
end
