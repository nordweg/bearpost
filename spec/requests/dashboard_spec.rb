require 'rails_helper'

RSpec.describe "Home", type: :request do
  before(:each) do
    user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password")
    sign_in user
  end
  describe "GET /dashboard" do
    it "works! (now write some real specs)" do
      get dashboard_path(date_range:"#{30.days.ago.strftime("%d/%m/%Y")} - #{Date.today.strftime("%d/%m/%Y")}")
      expect(response).to have_http_status(:success)
    end
  end
end
