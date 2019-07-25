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
    @shipment = Shipment.new
    @available_shipping_methods = get_shipping_methods
  end

  def new_from_xml
    @shipment             = Shipment.new
    doc = Nokogiri::XML(params[:invoice_xml]["invoice_xml"].read)
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
    @shipment.invoice_xml = doc.inner_html.strip
    @available_shipping_methods = get_shipping_methods
    render 'new'
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
    tracking_number = @carrier.get_tracking_number(@shipment)
    if tracking_number
      @shipment.update(tracking_number:tracking_number, status:'pronto')
      flash[:success] = 'Rastreio criado com sucesso.'
    else
      flash[:error] = 'Não foi possível criar número de rastreio.'
    end
    redirect_to @shipment
  end

  def get_labels
    if @shipment.requirements_missing.present?
      flash[:error] = @shipment.requirements_missing.first
      redirect_to @shipment and return
    end
    require "barby/barcode/code_128"
    require "barby/outputter/png_outputter"

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

  def send_to_carrier
    begin
      @carrier.send_to_carrier(@shipment)
      @shipment.update(sent_to_carrier:true)
      flash[:success] = 'Pedido enviado para a transportadora'
    rescue Exception => e
      flash[:error]  = e.message
    end
    redirect_to @shipment
  end

  def set_as_shipped
    @shipment.update(status:'shipped')
    redirect_to @shipment, notice: 'Pedido marcado como enviado'
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
        create_history(@shipment)
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
