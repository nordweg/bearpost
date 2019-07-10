module Api::V1
  class ApiController < ApplicationController

    # Generic API stuff here
    skip_before_action :authenticate_user!

    include ActionController::HttpAuthentication::Token::ControllerMethods
    before_action :authenticate

    protected

    # Authenticate the user with token based authentication
    def authenticate
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        @current_user = User.find_by(token: token)
      end
    end

    def render_unauthorized
      render json: 'Access denied', status: :unauthorized
    end
  end
end
