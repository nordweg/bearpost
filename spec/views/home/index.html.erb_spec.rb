require 'rails_helper'
require 'capybara/rails'

RSpec.describe "home/index.html.erb", type: :view do
  before(:each) do
    user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password")
    sign_in user
  end
  it "Shows bearpost logo" do
    visit "/"
    # expect(page).to have_content 'Bear Post'
    expect(page.find('#logo')['src']).to have_content 'initial-logo.png'
  end
end
