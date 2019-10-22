class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :save_tracking_number, :get_labels, :ship, :transmit_shipment_to_carrier, :set_as_shipped, :save_delivery_updates]
  before_action :set_carrier,  only: [:show, :save_delivery_updates, :get_labels, :transmit_shipment_to_carrier]

  def index
    @shipments = Shipment.filter(params)
    @shipments = @shipments.order(shipped_at: :desc).page(params[:page])
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
    begin
      flash[:success] = "Rastreio atualizado" if @shipment.get_tracking_number
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to @shipment
  end

  def get_labels
    require "barby/barcode/code_128"
    require "barby/outputter/png_outputter"
    @carrier.prepare_label(@shipment)
    respond_to do |format|
      format.html { render layout: 'pdf' }
      format.pdf { render pdf: "Etiqueta-#{@shipment.shipment_number}", template: "shipments/get_labels.html.erb"}
    end
  end

  def save_delivery_updates
    begin
      DeliveryStatusUpdater.update_shipment(@shipment)
      flash[:success] = "Rastreios atualizados com sucesso"
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to @shipment
  end

  def transmit_shipment_to_carrier
    begin
      response = @carrier.transmit_shipments([@shipment])
      response = response.first
      if response[:success] == true
        flash[:success] = response[:message]
      else
        flash[:error] = response[:message]
      end
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to @shipment
  end

  # Methods for all shipments

  def transmit_shipments_to_carriers
    shipments = Shipment.where(id:params[:shipment_ids])
    @transmit_results = ShipmentTransmitter.transmit(shipments)
    render 'transmit_results'
  end

  def update_all_shipments_delivery_status
    begin
      DeliveryStatusUpdater.update_all_shipments
      flash[:success] = "Rastreios atualizados com sucesso"
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to :shipments
  end

  private

  def set_shipment
    @shipment = Shipment.find(params[:id])
  end

  def set_carrier
    @carrier = @shipment.carrier
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_params
    if params[:invoice_xml] # REFACTOR > Should be in a model, maybe before_save? It doesn't feel right here
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
