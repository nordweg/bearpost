class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  protect_from_forgery with: :exception

  def selected_shipping_methods
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

  layout :layout_by_resource

  private

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
