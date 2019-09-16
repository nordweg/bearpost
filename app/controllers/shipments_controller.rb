class ShipmentsController < ApplicationController

  before_action :set_shipment, only: [:show, :edit, :update, :destroy, :get_tracking_number, :get_labels, :ship, :send_to_carrier, :set_as_shipped, :get_delivery_updates, :save_delivery_updates]
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
    @shipment = Shipment.new(get_info_from_xml)
  end

  def edit
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

  def save_delivery_updates # REFACTOR > Less logic? See https://github.com/spree/spree/blob/master/backend/app/controllers/spree/admin/orders_controller.rb
    # begin
      @shipment.save_delivery_updates
      flash[:success] = 'Histórico atualizado com sucesso'
    # rescue Exception => e
    #   flash[:error] = e.message
    # end
    redirect_to @shipment
  end

  def send_to_carriers # REFACTOR > Are we asking one shipment to send all shipments to all carriers? Maybe we should create a CarrierSynchonizer
    results = []
    available_carriers.each do |carrier|
      current_company.accounts.each do |account|
        shipments = Shipment.ready_to_ship.where(carrier_class: carrier.to_s, account_id: account.id)
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

  def send_to_carrier # Single shipment
    sync_result = @carrier.send_to_carrier([@shipment])
    message = sync_result.first[:message]
    sync_result.first[:success] ? flash[:success] = message : flash[:error] = message
    redirect_to @shipment
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
    hash[:state] = doc.at_css('dest UF').try(:content)
    hash[:country] = doc.at_css('dest xPais').try(:content)
    hash[:invoice_series] = doc.at_css('serie').try(:content)
    hash[:invoice_number] = doc.at_css('nNF').try(:content)
    hash[:cost] = doc.at_css('vNF').try(:content)
    hash[:invoice_xml] = doc.inner_html.strip
    hash
  end

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
    if params[:invoice_xml]
      params[:shipment][:invoice_xml] = params[:invoice_xml].read.strip
    end
    params.require(:shipment).permit!
  end
end
