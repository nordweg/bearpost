class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def selected_shipping_methods
    # {
    #   'Nordweg': {
    #     'Correios': {
    #       'PAC', { shipping_method_id: 1 }
    #       'SEDEX', 2
    #     }
    #   },
    #   'Emme': {
    #     'Correios': {
    #       'SEDEX10': 12
    #     }
    #   }
    # }
    hash = {}
    Account.all.each do |account|
      hash[account.name] = {}
      Rails.configuration.carriers.each do |carrier|
        hash[account.name][carrier.display_name] = {}
        hash[account.name][carrier.display_name] = account.selected_shipping_methods(carrier)
      end
    end
    hash
  end


end
