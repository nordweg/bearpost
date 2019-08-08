require 'rails_helper'

RSpec.describe "users/edit", type: :view do
  before(:each) do
    company = Company.create!()
    user = User.create!(email: 'test@test.com', password: "password", password_confirmation: "password", company:company)
    @user = assign(:user, user)
  end

  it "renders the edit user form" do
    render

    assert_select "form[action=?][method=?]", user_path(@user), "post" do
    end
  end
end
