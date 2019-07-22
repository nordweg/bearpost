class CarriersController < ApplicationController
  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = current_company.accounts
  end
  def edit
    @carrier = "Carrier::#{params[:id].titleize}".constantize
    @accounts = current_company.accounts
  end
end
