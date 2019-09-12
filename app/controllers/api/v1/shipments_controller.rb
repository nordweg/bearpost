module Api::V1
  class ShipmentsController < ApiController

    def index
      render json: current_company.shipments
    end

    def create
      if request.format.xml?
        shipment = current_company.shipments.new(shipment_info_from_xml)
      else
        shipment = current_company.shipments.new(shipment_params)
      end
      hande_save(shipment)
    end

    def update
      shipment = get_shipment
      shipment.assign_attributes(shipment_params)
      hande_save(shipment)
    end

    def update_invoice_xml
      shipment = get_shipment
      shipment.invoice_xml = request.body.read.strip
      hande_save(shipment)
    end

    def get_tracking_number
      shipment = get_shipment
      carrier  = get_carrier(shipment)
      shipment.tracking_number = carrier.get_tracking_number(shipment)
      hande_save(shipment)
    end

    def get_labels
      require "barby/barcode/code_128"
      require "barby/outputter/png_outputter"
      shipment = get_shipment
      carrier  = get_carrier(shipment)
      carrier.prepare_label(shipment)
      pdf_html = ActionController::Base.new.render_to_string(
        template: 'api/v1/labels.html.erb',
        locals: {shipment:shipment, carrier:carrier}
      )
      pdf      = WickedPdf.new.pdf_from_string(pdf_html)
      send_data pdf, filename: 'file.pdf'
    end

    def send_to_carrier
      shipment = get_shipment
      carrier  = get_carrier(shipment)
      carrier.send_to_carrier(shipment)
      shipment.sent_to_carrier = true
      hande_save(shipment)
    end

    def set_as_shipped
      shipment = get_shipment
      shipment.status = 'shipped'
      shipment.shipped_at = DateTime.now
      hande_save(shipment)
    end

    def hande_save(shipment)
      if shipment.save
        render json: shipment.to_json(except: [:invoice_xml])
      else
        render json: shipment.errors.full_messages
      end
    end

    private

    def get_shipment
      shipment = current_company.shipments.find_by(shipment_number:params[:id])
      raise Exception.new('Shipment not found') if shipment.blank?
      shipment
    end

    def get_carrier(shipment)
      carrier = shipment.carrier.new(shipment.carrier_setting)
      raise Exception.new('Carrier not found') if carrier.blank?
      carrier
    end

    def shipment_params
      if params[:shipment][:account]
        params[:shipment][:account] = Account.find_by!(name:params[:shipment][:account])
      end
      if params[:shipment][:carrier]
        params[:shipment][:carrier_class]
        params[:shipment].delete :carrier
      end
      params.require(:shipment).permit!
    end

    def shipment_info_from_xml
      doc = Nokogiri::XML(request.body.read)
      name       = doc.at_css('dest xNome').content
      first_name = name.split(" ").first
      last_name  = name.gsub(first_name, "").strip
      hash = {}
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
      hash[:shipment_number] = "#{doc.at_css('serie').try(:content)}_#{doc.at_css('nNF').try(:content)}"
      hash[:invoice_xml] = doc.inner_html.strip
      hash
    end
  end
end
