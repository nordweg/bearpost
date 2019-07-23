class CarriersController < ApplicationController
  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = current_company.accounts
  end
  def edit
    @carrier = helpers.carrier_from_id(params[:id])
    @accounts = current_company.accounts
  end
end
