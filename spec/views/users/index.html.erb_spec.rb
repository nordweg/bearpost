require 'rails_helper'

RSpec.describe "users/index", type: :view do
  before(:each) do
    company = Company.create!()
    user = User.create!(email: 'test@test.com', password: "password", password_confirmation: "password", company:company)
    assign(:users, [
      user, user
    ])
  end

  it "renders a list of users" do
    render
  end
end
