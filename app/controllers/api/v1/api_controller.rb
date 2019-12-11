module Api::V1
  class ApiController < ApplicationController
    protect_from_forgery unless: -> { request.format.json? || request.format.xml? || request.format.pdf? }

    skip_before_action :authenticate_user!
    before_action      :authenticate_connection!
    before_action      :set_current_attributes

    protected

    # Authenticate the user with token based authentication
    def authenticate_connection!
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      authenticate_with_http_token do |token, options|
        Setting.find_by(key: "api_key", value: token)
      end
    end

    def set_current_attributes
      Current.connected = "API"
    end

    def render_unauthorized
      render json: {status: "error", message:"Credenciais inválidas"}, status: :unauthorized
    end

    rescue_from Exception do |e|
      render json: {
        status: "error",
        message: e.message
        }, status: 500
    end
  end
end
