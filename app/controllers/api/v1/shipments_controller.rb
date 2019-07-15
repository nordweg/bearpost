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
      byebug
      hande_save(shipment)
    end

    def get_tracking_number
      shipment = get_shipment
      carrier  = get_carrier(shipment)
      shipment.tracking_number = carrier.get_tracking_number(shipment)
      hande_save(shipment)
    end

    def ship
      shipment = get_shipment
      if shipment.requirements_missing.present?
        render json: shipment.requirements_missing
      else
        carrier  = get_carrier(shipment)
        carrier.ship(shipment)
      end
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
      carrier = shipment.carrier
      raise Exception.new('Carrier not found') if carrier.blank?
      carrier
    end

    def shipment_params
      if params[:shipment][:account]
        params[:shipment][:account] = current_company.accounts.find_by(name:params[:shipment][:account])
      end
      params.require(:shipment).permit!
    end

    def shipment_info_from_xml
      doc = Nokogiri::XML(request.body.read)
      recipient_name       = doc.at_css('dest xNome').content
      recipient_first_name = recipient_name.split(" ").first
      recipient_last_name  = recipient_name.gsub(recipient_first_name, "").strip
      sender_name       = doc.at_css('emit xNome').content
      sender_first_name = sender_name.split(" ").first
      sender_last_name  = sender_name.gsub(sender_first_name, "").strip
      hash = {}
      hash[:recipient_first_name] = recipient_first_name
      hash[:recipient_last_name] = recipient_last_name
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
      hash[:sender_first_name] = sender_first_name
      hash[:sender_last_name] = sender_last_name
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
      hash[:shipment_number] = "#{doc.at_css('serie').try(:content)}_#{doc.at_css('nNF').try(:content)}"
      hash[:invoice_xml] = doc.inner_html.strip
      hash
    end
  end
end
