module Api::V1
  class ApiController < ApplicationController
    # Generic API stuff here

    protect_from_forgery unless: -> { request.format.json? || request.format.xml? || request.format.pdf? }

    skip_before_action :authenticate_user!
    before_action      :authenticate_company!

    protected

    # Authenticate the user with token based authentication
    def authenticate_company!
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        @current_company = Company.find_by(token: token)
      end
    end

    def current_company
      @current_company
    end

    def set_current_user
      Current.connected = "API"
    end

    def render_unauthorized
      render json: 'Credenciais inválidas'.to_json, status: :unauthorized
    end

    rescue_from Exception do |e|
      render json: {
        status: "error",
        message: e.message
        }, status: 500
    end
  end
end
