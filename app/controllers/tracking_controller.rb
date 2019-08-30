class TrackingController < ApplicationController
  def show
    @shipment = Shipment.find_by(shipment_number:params[:shipment_number])
    render :layout => false
  end
end
