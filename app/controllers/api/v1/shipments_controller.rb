module Api::V1
  class ShipmentsController < ApiController

    # GET /v1/shipments
    def index
      render json: current_user.shipments.as_json(except: [:invoice_xml])
    end

  end
end
