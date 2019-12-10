module Api::V1
  class CarriersController < ApiController

    def index
      render json: Carriers.names_and_services
    end

  end
end
