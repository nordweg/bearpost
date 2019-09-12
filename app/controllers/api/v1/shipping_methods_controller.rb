module Api::V1
  class ShippingMethodsController < ApiController

    def index
      hash = {}
      current_company.accounts.each do |account|
        hash[account.name] = {}
        Rails.configuration.carriers.each do |carrier|
          hash[account.name][carrier.name] = {}
          hash[account.name][carrier.name] = account.selected_shipping_methods(carrier)
        end
      end
      render json: hash
    end

  end
end
