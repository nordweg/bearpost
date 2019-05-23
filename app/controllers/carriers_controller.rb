class CarriersController < ApplicationController
  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = Account.all
  end
  def edit
    @carrier = "Carrier::#{params[:id].titleize}".constantize
    @accounts = Account.all
    @account = Account.last
  end
end
