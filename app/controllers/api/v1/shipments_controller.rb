module Api::V1
  class ShipmentsController < ApiController

    # GET /v1/shipments
    def index
      render json: current_user.shipments.as_json(
        except: [:invoice_xml],
        include: { packages: { only: [:number] } }
      )
    end

    # POST /shipments.json
    def create
      if request.format.xml?
        set_params_from_xml
      end

      shipment = current_user.shipments.new(shipment_params)

      if shipment.save
        render json: shipment.as_json(except: [:invoice_xml,:user_id])
      else
        byebug
        render json: shipment.errors.full_messages
      end
    end

    private

    def shipment_params
      params.require(:shipment).permit!
    end

    def set_params_from_xml
      doc = Nokogiri::XML(request.body.read)

      name = doc.at_css('dest xNome').content
      first_name = name.split(" ").first
      last_name  = name.gsub(first_name, "").strip

      params[:shipment] = ActionController::Parameters.new
      params[:shipment][:recipient_first_name] = first_name
      params[:shipment][:recipient_last_name] = last_name
      params[:shipment][:recipient_email] = doc.at_css('dest email').try(:content)
      params[:shipment][:recipient_phone] = doc.at_css('dest fone').try(:content)
      params[:shipment][:recipient_cpf] = doc.at_css('dest CPF').try(:content)
      params[:shipment][:recipient_street] = doc.at_css('dest xLgr').try(:content)
      params[:shipment][:recipient_number] = doc.at_css('dest nro').try(:content)
      params[:shipment][:recipient_complement] = doc.at_css('dest xCpl').try(:content)
      params[:shipment][:recipient_neighborhood] = doc.at_css('dest xBairro').try(:content)
      params[:shipment][:recipient_zip] = doc.at_css('dest CEP').try(:content)
      params[:shipment][:recipient_city] = doc.at_css('dest xMun').try(:content)
      params[:shipment][:recipient_city_code] = doc.at_css('dest cMun').try(:content)
      params[:shipment][:recipient_state] = doc.at_css('dest UF').try(:content)
      params[:shipment][:recipient_country] = doc.at_css('dest xPais').try(:content)

      name = doc.at_css('emit xNome').content
      first_name = name.split(" ").first
      last_name  = name.gsub(first_name, "").strip

      params[:shipment][:sender_first_name] = first_name
      params[:shipment][:sender_last_name] = last_name
      params[:shipment][:sender_email] = doc.at_css('emit email').try(:content)
      params[:shipment][:sender_phone] = doc.at_css('emit fone').try(:content)
      params[:shipment][:sender_cpf] = doc.at_css('emit CNPJ').try(:content)
      params[:shipment][:sender_street] = doc.at_css('emit xLgr').try(:content)
      params[:shipment][:sender_number] = doc.at_css('emit nro').try(:content)
      params[:shipment][:sender_complement] = doc.at_css('emit xCpl').try(:content)
      params[:shipment][:sender_neighborhood] = doc.at_css('emit xBairro').try(:content)
      params[:shipment][:sender_zip] = doc.at_css('emit CEP').try(:content)
      params[:shipment][:sender_city] = doc.at_css('emit xMun').try(:content)
      params[:shipment][:sender_city_code] = doc.at_css('emit cMun').try(:content)
      params[:shipment][:sender_state] = doc.at_css('emit UF').try(:content)
      params[:shipment][:sender_country] = doc.at_css('emit xPais').try(:content)

      params[:shipment][:invoice_series] = doc.at_css('serie').try(:content)
      params[:shipment][:invoice_number] = doc.at_css('nNF').try(:content)

      params[:shipment][:cost] = doc.at_css('vNF').try(:content)

      params[:shipment][:shipment_number] = "#{doc.at_css('serie').try(:content)}_#{doc.at_css('nNF').try(:content)}"
    end

  end
end
