module Api::V1
  class ShippingMethodsController < ApiController

    def index
      array = []
      Carriers.all.each do |carrier|
        carrier_hash = {}
        carrier_hash[:carrier] = carrier.name
        carrier_hash[:shipping_methods] = carrier.shipping_methods
        array << carrier_hash
      end
      array
      render json: array
    end

  end
end
