class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_current_user

  layout :layout_by_resource

  def available_carriers
    Rails.configuration.carriers
  end

  private

  def set_current_user
    Current.user = current_user
  end

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
end
