require 'rails_helper'

RSpec.describe "Home", type: :request do
  before(:each) do
    user = User.create(email: 'test@test.com', password: "password", password_confirmation: "password")
    sign_in user
  end
  describe "GET /" do
    it "works! (now write some real specs)" do
      get root_path
      expect(response).to have_http_status(:success)
    end
  end
end
