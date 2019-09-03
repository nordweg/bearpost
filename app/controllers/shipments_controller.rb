class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number,
     :get_labels, :ship, :send_to_carrier, :set_as_shipped, :get_delivery_updates]
  # include ApplicationHelper

  def index
    if params[:search].present?
      @shipments = Shipment.where(
        "CONCAT(first_name, ' ' ,last_name) ILIKE :search
        OR regexp_replace(cpf, '\\D', '', 'g') ILIKE regexp_replace(:search, '\\D', '', 'g')
        OR order_number ILIKE :search
        OR city ILIKE :search",
        search: "%#{params[:search]}%"
      )
    else
      @shipments = Shipment.all
    end
    @shipments = @shipments.where(status:params[:status]) if params[:status].present?
    @shipments = @shipments.where(carrier_id:params[:carrier]) if params[:carrier].present?
    if params[:date_range].present?
      start_date = DateTime.parse(params[:date_range][0..9]).beginning_of_day
      end_date = DateTime.parse(params[:date_range][13..-1]).end_of_day
      @shipments = @shipments.where("created_at > ? AND created_at < ?", start_date, end_date)
    end
    @shipments = @shipments.order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    shipment_data = params[:invoice_xml] ? get_info_from_xml : nil
    @shipment = Shipment.new(shipment_data)
    @available_shipping_methods = get_shipping_methods
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

  def set_as_shipped
    @shipment.update(status:'shipped')
    redirect_to @shipment
  end

  def get_delivery_updates
    begin
      delivery_updates = @carrier.get_delivery_updates(@shipment)
      delivery_updates.each do |delivery_update|
        next if @shipment.histories.find_by(description:delivery_update[:description], date:delivery_update[:date])
        @shipment.histories.create(
          description: delivery_update[:description],
          date: delivery_update[:date],
          changed_by: @carrier.display_name,
          category: 'carrier',
        )
      end
      flash[:success] = 'Histórico atualizado'
    rescue Exception => e
      flash[:error] = e.message
    end
    redirect_to @shipment
  end

  def send_to_carriers
    results = []
    available_carriers.each do |carrier|
      current_company.accounts.each do |account|
        shipments = Shipment.ready_to_ship.where(carrier_id: carrier.id, account_id: account.id)
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

  def send_to_carrier # POST route for sending a single shipment to carrier
    raise Exception.new('Carrier not found') if @carrier.blank?
    sync_result = @carrier.send_to_carrier([@shipment])
    message = sync_result.first[:message]
    sync_result.first[:success] ? flash[:success] = message : flash[:error] = message
    redirect_to @shipment
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

  def get_info_from_xml
    hash = {}
    doc = Nokogiri::XML(params[:invoice_xml]["invoice_xml"].read)
    name = doc.at_css('dest xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip
    hash[:first_name] = first_name
    hash[:last_name] = last_name
    hash[:email] = doc.at_css('dest email').try(:content)
    hash[:phone] = doc.at_css('dest fone').try(:content)
    hash[:cpf] = doc.at_css('dest CPF').try(:content)
    hash[:street] = doc.at_css('dest xLgr').try(:content)
    hash[:number] = doc.at_css('dest nro').try(:content)
    hash[:complement] = doc.at_css('dest xCpl').try(:content)
    hash[:neighborhood] = doc.at_css('dest xBairro').try(:content)
    hash[:zip] = doc.at_css('dest CEP').try(:content)
    hash[:city] = doc.at_css('dest xMun').try(:content)
    hash[:city_code] = doc.at_css('dest cMun').try(:content)
    hash[:state] = doc.at_css('dest UF').try(:content)
    hash[:country] = doc.at_css('dest xPais').try(:content)
    hash[:invoice_series] = doc.at_css('serie').try(:content)
    hash[:invoice_number] = doc.at_css('nNF').try(:content)
    hash[:cost] = doc.at_css('vNF').try(:content)
    hash[:invoice_xml] = doc.inner_html.strip
    hash
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_shipment
    @shipment = Shipment.find(params[:id])
    @carrier  = helpers.carrier_from_id(@shipment.carrier_id) rescue nil
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def shipment_params
    if params[:invoice_xml]
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
