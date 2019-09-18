class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number, :get_labels, :ship, :sync_with_carrier, :set_as_shipped, :get_delivery_updates, :save_delivery_updates]
  before_action :set_carrier, only: [:show, :get_delivery_updates, :save_delivery_updates]

  def index
    @shipments = Shipment.filter(params)
    @shipments = @shipments.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    @shipment = Shipment.new
  end

  def new_from_xml
    parsed_nf_xml = NotaFiscalParser.parse(params[:invoice_xml]["invoice_xml"].read)
    @shipment = Shipment.new(parsed_nf_xml)
    render :new 
  end

  def edit
  end

  def create
    @shipment = Shipment.new(shipment_params)
    @shipment.company = current_user.company
    if @shipment.save
      redirect_to @shipment, notice: 'O envio foi criado com sucesso!'
    else
      flash[:error] = @shipment.errors.full_messages
      render :new
    end
  end

  def update
    if @shipment.update(shipment_params)
      redirect_to @shipment, notice: 'O envio foi atualizado com sucesso!'
    else
      render :edit
    end
  end

  def destroy
    @shipment.destroy
    redirect_to shipments_url, notice: 'O envio apagado com sucesso!'
  end

  def save_tracking_number
    tracking_number = @shipment.get_tracking_number
    @shipment.update(tracking_number: tracking_number)
    redirect_to @shipment
  end

  def get_labels
    require "barby/barcode/code_128"
    require "barby/outputter/png_outputter"
    @carrier.prepare_label(@shipment)
    respond_to do |format|
      format.html { render layout: 'pdf' }
      format.pdf { render pdf: "Etiqueta-#{@shipment.shipment_number}", template: "shipments/get_labels.html.erb" }
    end
  end

  def save_delivery_updates
    if @shipment.save_delivery_updates
      flash[:success] = 'Histórico atualizado com sucesso'
    else
      flash[:error] = @shipment.errors.full_messages
    end
    redirect_to @shipment
  end

  def sync_all_ready_shipments_with_carriers
    shipments = Shipment.all.ready_to_ship
    CarrierSyncronizer.sync(shipments)
  end

  def sync_shipment_with_carrier
    sync_result = CarrierSyncronizer.sync([@shipment])
    message = sync_result.first[:message]
    sync_result.first[:success] ? flash[:success] = message : flash[:error] = message
    redirect_to @shipment
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_shipment # REFACTOR > It's also setting carrier, which needs authentication just to view shipment. Make single responsability. No need to autenticate with carrier just to view shipment
    @shipment = Shipment.find(params[:id])
    # @carrier = @shipment.carrier.new(@shipment.carrier_settings)
    # if @carrier.valid_credentials? == false # REFACTOR > This was making viewing a shipment slow. What's the need to authenticate with carrier at this state?
    #   @carrier.authenticate!
    # end
  end

  def set_carrier
    @carrier = @shipment.carrier.new(@shipment.carrier_settings)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_params
    if params[:invoice_xml] # REFACTOR > Should be in a model, maybe before_save?
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
