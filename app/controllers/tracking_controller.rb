class TrackingController < ApplicationController
  def show
    @shipment = Shipment.find_by(shipment_number:params[:shipment_number])
    if @shipment && @shipment.tracking_number
      redirect_to(@shipment.tracking_url)
    else
      render :layout => false
    end
  end
end
