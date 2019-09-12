class CarriersController < ApplicationController
  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = current_company.accounts
  end
  def edit
    @carrier = Carriers.find(params[:id])
    @accounts = current_company.accounts
  end
  def send_to_carrier
    @carrier  = Object.const_get params[:id]
    shipments = current_company.shipments.ready_to_ship.where(carrier_class: @carrier.to_s)
    begin
      shipments.each do |shipment|
        @carrier.send_to_carrier(shipment)
        shipment.sent_to_carrier!
      end
      flash[:success] = 'Todos pedidos foram sincronizados'
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to edit_carrier_path(@carrier)
  end
  def validate_credentials_ajax
    begin
      @carrier = Object.const_get params[:carrier_class]
      carrier_settings = Account.find(params[:account_id]).carrier_settings.carrier(@carrier)
      @carrier.new(carrier_settings).valid_credentials?
      render json: "Credenciais válidas".to_json
    rescue Exception => e
      render json: e.message.to_json
    end
  end
end
