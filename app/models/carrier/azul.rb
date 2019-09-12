class Carrier::Azul < Carrier
  cattr_reader :name
  @@name = "Azul Cargo"

  LIVE_URL = "http://ediapi.onlineapp.com.br"
  TEST_URL = "http://hmg.onlineapp.com.br/WebAPI_EdiAzulCargo"
  SERVICES = ['Standart']

  def self.settings
    ['email','password','document']
  end

  def self.shipping_methods
    ['Standart']
  end

  def self.tracking_url
    "http://www.azulcargo.com.br/Rastreio.aspx?n={tracking}&tipoAwb=Nacional"
  end

  def valid_credentials?
    authenticate_user(
      settings["email"],
      settings["password"],
      settings["document"]
    )
  end

  def get_delivery_updates(shipment)
    check_tracking_number(shipment)
    token = settings['token']
    response = connection.get("api/Ocorrencias/Consultar?Token=#{token}&AWB=#{shipment.tracking_number}")
    check_response(response)
    events = response.body.dig("Value",0,"Ocorrencias")
    events.each do |event|
      history = shipment.histories.find_by(description:event["Descricao"])
      next if history.present?
      description = "#{event["Descricao"]} - #{event["UnidadeMunicipio"]}, #{event["UnidadeUF"]}"
      shipment.histories.create(
        description: description,
        city: event["UnidadeMunicipio"],
        state: event["UnidadeUF"],
        date: event["DataHora"],
        changed_by: 'Azul',
        category: 'carrier'
      )
    end
  end

  def authenticate!
    token_expire_date = settings['token_expire_date'].try(:to_datetime)
    if token_expire_date.blank? || token_expire_date < DateTime.now
      renew_token
    end
  end

  def renew_token
    user     = settings['email']
    password = settings['password']
    cpf_cnpj = settings['document']
    response = authenticate_user(user, password, cpf_cnpj)
    token    = response.body["Value"]
    settings['token'] = token
    settings['token_expire_date'] = DateTime.now + 7.hours
    carrier_setting.save
  end

  def check_tracking_number(shipment)
    raise Exception.new("Azul - Este envio não tem um código de rastreio (AWB)") if shipment.tracking_number.blank?
  end

  def check_response(response)
    if response.body["HasErrors"]
      raise Exception.new("Azul - #{response.body["ErrorText"]}")
    elsif response.body["Value"].empty?
      raise Exception.new("Ainda não há informações de rastreamento. Tente mais tarde.")
    end
  end

  def connection
    url = test_mode? ? TEST_URL : LIVE_URL
    Faraday.new(url: url) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end

  def authenticate_user(user, password, cpf_cnpj)
    credentials = {
        "Email" => user,
        "Senha" => password,
        "CpfCnpj" => cpf_cnpj
    }
    response = connection.post("api/Autenticacao/ValidarUsuarioPortalClienteEdi", credentials)
    if response.body["HasErrors"]
      raise Exception.new("Azul - Authentication Error: #{response.body["ErrorText"]}")
    else
      response
    end
  end

  def get_tracking_number(shipment)
    authenticate!
    check_invoice_xml(shipment)
    get_awb(shipment)
  end

  def check_invoice_xml(shipment)
    raise Exception.new("Azul - É necessário o XML da nota fiscal") if shipment.invoice_xml.blank?
  end

  def get_awb(shipment)
    xml = Nokogiri::XML(shipment.invoice_xml)
    str = xml.at_css('infNFe').attribute("Id").try(:content)
    nfe_key = str[3..-1]
    token = settings['token']
    response = connection.get("api/Ocorrencias/Consultar?token=#{token}&ChaveNFE=#{nfe_key}")
    check_response(response)
    response.body.dig("Value",0,"Awb")
  end

  def check_for_updates
    shipments.each do |shipment|
      get_updates(shipment)
    end
  end

  def send_to_carrier(shipments)
    response = []
    shipments.each do |shipment|
      begin
        check_invoice_xml(shipment)
        encoded_xml = Base64.strict_encode64(shipment.invoice_xml)
        faraday_response = send_to_azul(encoded_xml)
        message = faraday_response.body["HasErrors"] ? faraday_response.body["ErrorText"] : faraday_response.body["Value"]
        shipment.update(sent_to_carrier:true) unless faraday_response.body["HasErrors"]
        response << {
          shipment: shipment,
          success: shipment.sent_to_carrier,
          message: message
        }
      rescue  Exception => e
        response << {
          shipment: shipment,
          success: shipment.sent_to_carrier,
          message: e.message
        }
      end
    end
    response
  end

  def send_to_azul(encoded_xml)
    token = settings['token']
    body  = {
      "xml": encoded_xml,
    }
    response = connection.post("api/NFe/Enviar?token=#{token}",body)
  end
end
