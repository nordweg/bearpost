class CarriersController < ApplicationController
  def index
    @carriers = Rails.configuration.carriers.sort_by(&:name)
    @accounts = current_company.accounts
  end
  def edit
    @carrier = helpers.carrier_from_id(params[:id])
    @accounts = current_company.accounts
  end
  def send_to_carrier
    @carrier  = helpers.carrier_from_id(params[:id])
    shipments = current_company.shipments.ready.where(carrier_id:@carrier.id)
    begin
      shipments.each do |shipment|
        @carrier.send_to_carrier(shipment)
        shipment.sent_to_carrier!
      end
      flash[:success] = 'Todos pedidos foram sincronizados'
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to edit_carrier_path(@carrier.id)
  end
end
