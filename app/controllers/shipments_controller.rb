class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number,
     :get_labels, :ship, :send_to_carrier, :set_as_shipped]
  # include ApplicationHelper

  def index
    @shipments = current_user.shipments
  end

  def show
  end

  def new
    shipment_data = params[:invoice_xml] ? get_info_from_xml : nil
    @shipment = Shipment.new(shipment_data)
    @available_shipping_methods = get_shipping_methods
  end

  def get_info_from_xml
    hash = {}
    doc = Nokogiri::XML(params[:invoice_xml]["invoice_xml"].read)
    name = doc.at_css('dest xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip
    hash[:recipient_first_name] = first_name
    hash[:recipient_last_name] = last_name
    hash[:recipient_email] = doc.at_css('dest email').try(:content)
    hash[:recipient_phone] = doc.at_css('dest fone').try(:content)
    hash[:recipient_cpf] = doc.at_css('dest CPF').try(:content)
    hash[:recipient_street] = doc.at_css('dest xLgr').try(:content)
    hash[:recipient_number] = doc.at_css('dest nro').try(:content)
    hash[:recipient_complement] = doc.at_css('dest xCpl').try(:content)
    hash[:recipient_neighborhood] = doc.at_css('dest xBairro').try(:content)
    hash[:recipient_zip] = doc.at_css('dest CEP').try(:content)
    hash[:recipient_city] = doc.at_css('dest xMun').try(:content)
    hash[:recipient_city_code] = doc.at_css('dest cMun').try(:content)
    hash[:recipient_state] = doc.at_css('dest UF').try(:content)
    hash[:recipient_country] = doc.at_css('dest xPais').try(:content)
    name = doc.at_css('emit xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip
    hash[:sender_first_name] = first_name
    hash[:sender_last_name] = last_name
    hash[:sender_email] = doc.at_css('emit email').try(:content)
    hash[:sender_phone] = doc.at_css('emit fone').try(:content)
    hash[:sender_cpf] = doc.at_css('emit CNPJ').try(:content)
    hash[:sender_street] = doc.at_css('emit xLgr').try(:content)
    hash[:sender_number] = doc.at_css('emit nro').try(:content)
    hash[:sender_complement] = doc.at_css('emit xCpl').try(:content)
    hash[:sender_neighborhood] = doc.at_css('emit xBairro').try(:content)
    hash[:sender_zip] = doc.at_css('emit CEP').try(:content)
    hash[:sender_city] = doc.at_css('emit xMun').try(:content)
    hash[:sender_city_code] = doc.at_css('emit cMun').try(:content)
    hash[:sender_state] = doc.at_css('emit UF').try(:content)
    hash[:sender_country] = doc.at_css('emit xPais').try(:content)
    hash[:invoice_series] = doc.at_css('serie').try(:content)
    hash[:invoice_number] = doc.at_css('nNF').try(:content)
    hash[:cost] = doc.at_css('vNF').try(:content)
    hash[:invoice_xml] = doc.inner_html.strip
    hash
  end

  # GET /shipments/1/edit
  def edit
    @available_shipping_methods = get_shipping_methods
  end

  def get_shipping_methods
    hash = {}
    current_user.company.accounts.each do |account|
      hash[account.name] = {}
      Rails.configuration.carriers.each do |carrier|
        hash[account.name][carrier.display_name] = {}
        hash[account.name][carrier.display_name] = account.selected_shipping_methods(carrier)
      end
    end
    hash
  end

  def get_tracking_number
    begin
      tracking_number = @carrier.get_tracking_number(@shipment)
      @shipment.update(tracking_number:tracking_number)
      flash[:success] = 'Rastreio atualizado'
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
      format.html do
        render layout: 'pdf'
      end
      format.pdf do
        render pdf: "Etiqueta-#{@shipment.shipment_number}",
        template: "shipments/get_labels.html.erb"
      end
    end
  end

  def send_to_carrier # POST route for sending a single shipment to carrier
    raise Exception.new('Carrier not found') if @carrier.blank?
    sync_result = @carrier.send_to_carrier([@shipment])
    message = sync_result.first[:message]
    sync_result.first[:success] ? flash[:success] = message : flash[:error] = message
    redirect_to @shipment
  end

  def set_as_shipped
    @shipment.update(status:'shipped')
    redirect_to @shipment
  end

  def send_to_carriers
    results = []
    available_carriers.each do |carrier|
      current_company.accounts.each do |account|
        shipments = Shipment.ready_to_ship.where(carrier_name: carrier.id, account_id: account.id)
        carrier_hash = {
          account: account,
          carrier: carrier,
          sync_result: carrier.send_to_carrier(shipments)
        }
        results << carrier_hash
      end
    end
    @results = results
    respond_to do |format|
      format.html
      format.json { render json: @results.to_json }
    end
  end

  def create
    @shipment         = Shipment.new(shipment_params)
    @shipment.company = current_user.company
    respond_to do |format|
      if @shipment.save
        format.html { redirect_to @shipment, notice: 'Shipment was successfully created.' }
        format.json { render :show, status: :created, location: @shipment }
      else
        format.html {
          flash[:error] = @shipment.errors.full_messages
          render :new
        }
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
    @carrier  = helpers.carrier_from_id(@shipment.carrier_name) rescue nil
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_params
    if params[:invoice_xml]
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
