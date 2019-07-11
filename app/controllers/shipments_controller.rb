class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number, :get_labels]
  # include ApplicationHelper

  # GET /shipments
  # GET /shipments.json
  def index
    @shipments = current_user.shipments
  end

  # GET /shipments/1
  # GET /shipments/1.json
  def show
  end

  # GET /shipments/new
  def new
    @shipment = Shipment.new
  end

  def new_from_xml
    @shipment         = Shipment.new
    @shipment.invoice_xml = params[:invoice_xml]["invoice_xml"].read.strip
    doc = Nokogiri::XML(@shipment.invoice_xml)

    name = doc.at_css('dest xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip

    @shipment.recipient_first_name = first_name
    @shipment.recipient_last_name = last_name
    @shipment.recipient_email = doc.at_css('dest email').try(:content)
    @shipment.recipient_phone = doc.at_css('dest fone').try(:content)
    @shipment.recipient_cpf = doc.at_css('dest CPF').try(:content)
    @shipment.recipient_street = doc.at_css('dest xLgr').try(:content)
    @shipment.recipient_number = doc.at_css('dest nro').try(:content)
    @shipment.recipient_complement = doc.at_css('dest xCpl').try(:content)
    @shipment.recipient_neighborhood = doc.at_css('dest xBairro').try(:content)
    @shipment.recipient_zip = doc.at_css('dest CEP').try(:content)
    @shipment.recipient_city = doc.at_css('dest xMun').try(:content)
    @shipment.recipient_city_code = doc.at_css('dest cMun').try(:content)
    @shipment.recipient_state = doc.at_css('dest UF').try(:content)
    @shipment.recipient_country = doc.at_css('dest xPais').try(:content)

    name = doc.at_css('emit xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip

    @shipment.sender_first_name = first_name
    @shipment.sender_last_name = last_name
    @shipment.sender_email = doc.at_css('emit email').try(:content)
    @shipment.sender_phone = doc.at_css('emit fone').try(:content)
    @shipment.sender_cpf = doc.at_css('emit CNPJ').try(:content)
    @shipment.sender_street = doc.at_css('emit xLgr').try(:content)
    @shipment.sender_number = doc.at_css('emit nro').try(:content)
    @shipment.sender_complement = doc.at_css('emit xCpl').try(:content)
    @shipment.sender_neighborhood = doc.at_css('emit xBairro').try(:content)
    @shipment.sender_zip = doc.at_css('emit CEP').try(:content)
    @shipment.sender_city = doc.at_css('emit xMun').try(:content)
    @shipment.sender_city_code = doc.at_css('emit cMun').try(:content)
    @shipment.sender_state = doc.at_css('emit UF').try(:content)
    @shipment.sender_country = doc.at_css('emit xPais').try(:content)

    @shipment.invoice_series = doc.at_css('serie').try(:content)
    @shipment.invoice_number = doc.at_css('nNF').try(:content)

    @shipment.cost = doc.at_css('vNF').try(:content)

    puts doc.to_xml(:indent => 2)
    render 'new'
  end

  # GET /shipments/1/edit
  def edit
    @accounts_and_shipping_methods = selected_shipping_methods
  end

  def get_tracking_number
    tracking_number = @carrier.get_tracking_number(@shipment)
    if tracking_number
      @shipment.update(tracking_number:tracking_number, status:'pronto')
      redirect_to @shipment, notice: 'Rastreio criado com sucesso.'
    else
      redirect_to @shipment, notice: 'Não foi possível criar número de rastreio.'
    end
  end

  def get_labels
    require "barby/barcode/code_128"
    require "barby/outputter/png_outputter"

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
    @shipment         = Shipment.new(shipment_params)
    @shipment.user    = current_user
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
      # byebug
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
    @carrier  = helpers.carrier_from_id(@shipment.carrier_name) rescue nil
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_params
    # params.require(:shipment).permit(:shipment_number)
    if params[:invoice_xml]
      byebug
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
