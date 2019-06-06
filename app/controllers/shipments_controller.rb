class ShipmentsController < ApplicationController
  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number, :get_labels]
  # include ApplicationHelper

  # GET /shipments
  # GET /shipments.json
  def index
    @shipments = Shipment.all
  end

  # GET /shipments/1
  # GET /shipments/1.json
  def show
    if @shipment.carrier_name
      @carrier = helpers.carrier_from_id(@shipment.carrier_name)
    else
      @carrier = nil
    end
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  # GET /shipments/1/edit
  def edit
    @accounts_and_shipping_methods = selected_shipping_methods
  end

  def get_tracking_number
    @carrier        = helpers.carrier_from_id(@shipment.carrier_name)
    tracking_number = @carrier.get_tracking_number(@shipment)
    @shipment.update(tracking_number:tracking_number, status:'pronto')
    redirect_to @shipment, notice: 'Rastreio criado com sucesso.'
  end

  def get_labels
    @carrier = helpers.carrier_from_id(@shipment.carrier_name)
    get_tracking_number if @shipment.tracking_number.blank?
    respond_to do |format|
      format.html do
        render layout: 'pdf'
      end
      format.pdf do
        render pdf: "Etiqueta #{@shipment.shipment_number}",
        page_height: '155mm',
        page_width:  '105mm',
        template: "shipments/get_labels.html.erb",
        orientation: "Portrait",
        layout: 'pdf',
        zoom: 1,
        dpi: 203,
        margin:  {top:  0,bottom:0,left: 0,right:0}
      end
    end
  end

  def ship
    @carrier = helpers.carrier_from_id(@shipment.carrier_name)
    @carrier.ship
  end

  # POST /shipments
  # POST /shipments.json
  def create
    @shipment = Shipment.new(shipment_params)

    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: 'Shipment was successfully created.' }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html { render :new }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shipments/1
  # PATCH/PUT /shipments/1.json
  def update
    respond_to do |format|
      if @shipment.update(shipment_params)
        format.html { redirect_to @shipment, notice: 'Shipment was successfully updated.' }
        format.json { render :show, status: :ok, location: @shipment }
      else
        format.html { render :edit }
        format.json { render json: @shipment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipments/1
  # DELETE /shipments/1.json
  def destroy
    @shipment.destroy
    respond_to do |format|
      format.html { redirect_to shipments_url, notice: 'Shipment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipment
      @shipment = Shipment.find(params[:id])
    end

    def set_car
      @shipment = Shipment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipment_params
      # params.require(:shipment).permit(:shipment_number)
      params.require(:shipment).permit!
    end
end
