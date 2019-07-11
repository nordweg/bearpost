module Api::V1
  class ApiController < ApplicationController
    protect_from_forgery unless: -> { request.format.json? || request.format.xml? }
    respond_to :json

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
      render json: 'Credenciais inválidas', status: :unauthorized
    end

    rescue_from Exception do |e|
      render json: e.to_json, status: 500
    end
  end
end
