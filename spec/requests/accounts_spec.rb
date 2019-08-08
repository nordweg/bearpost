require 'rails_helper'
include Warden::Test::Helpers

RSpec.describe "Accounts", type: :request do
  before(:each) do
    user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password")
    sign_in user
  end
  describe "GET /accounts" do
    it "works! (now write some real specs)" do
      get accounts_path
      expect(response).to have_http_status(:success)
    end
  end
end
