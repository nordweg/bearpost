class CarriersController < ApplicationController

  before_action :set_carrier, only: [:edit, :transmit_ready_shipments, :validate_credentials_ajax]

  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = Account.all
  end

  def edit
    @accounts = Account.all
  end

  def validate_credentials_ajax
    begin
      carrier_settings = Account.find(params[:account_id]).carrier_settings.carrier(@carrier)
      carrier = @carrier.new(carrier_settings)
      response = carrier.authenticate!
      render json: response.to_json
    rescue Exception => e
      render json: e.message.to_json, status: 500
    end
  end

  def transmit_ready_shipments
    account = Account.find(params[:account])
    shipments = @carrier.shipments.ready_to_ship.not_transmitted.where(account:account)
    carrier_setting = CarrierSetting.find_by(carrier_class:@carrier.to_s, account:account)
    @carrier.new(carrier_setting).transmit_shipments(shipments) if shipments.any?
  end

  private

  def set_carrier
    @carrier = Carriers.find(params[:id])
  end

end
