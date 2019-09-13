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

  # MACRO STATUS
  # Aberto - Pending
  # Pronto para envio - Ready for shipment
  # A caminho - On the way
  # Saiu para entrega - Out for delivery
  # Entregue - Delivered
  # Com problema - Problematic
  # Retornado - Returned
  # Cancelado - Cancelled

  STATUS_CODES = {
    '1': {azul_status: 'ENTREGA REALIZADA NORMALMENTE', bearpost_status: 'Delivered'},
    '2': {azul_status: 'ENTREGA FORA DA DATA PROGRAMADA', bearpost_status: 'Delivered'},
    '3': {azul_status: 'RECUSA POR FALTA DE PEDIDO DE COMPRA', bearpost_status: 'Problematic'},
    '4': {azul_status: 'RECUSA POR PEDIDO DE COMPRA CANCELADO', bearpost_status: 'Problematic'},
    '5': {azul_status: 'FALTA DE ESPACO FISICO NO DEPOSITO DO CLIENTE  DE DESTINO', bearpost_status: 'Problematic'},
    '6': {azul_status: 'ENDERECO DO CLIENTE DESTINO NAO FOI LOCALIZADO.', bearpost_status: 'Problematic'},
    '7': {azul_status: 'DEVOLUCAO NAO AUTORIZADA PELO CLIENTE', bearpost_status: 'Problematic'},
    '8': {azul_status: 'PRECO DA MERCADORIA EM DESACORDO COM O PEDIDO DE COMPRA', bearpost_status: 'Problematic'},
    '9': {azul_status: 'MERCADORIA EM DESACORDO COM O PEDIDO DE COMPRA', bearpost_status: 'Problematic'},
    '10': {azul_status: 'CLIENTE DESTINO SOMENTE RECEBE MERCADORIA COM FRETE PAGO', bearpost_status: 'Problematic'},
    '11': {azul_status: 'RECUSA POR DEFICIENCIA EMBALAGEM MERCADORIA', bearpost_status: 'Problematic'},
    '12': {azul_status: 'REDESPACHO NAO INDICADO', bearpost_status: 'Problematic'},
    '13': {azul_status: 'TRANSPORTADORA NAO ATENDE A CIDADE DO CLIENTE DESTINO', bearpost_status: 'Problematic'},
    '14': {azul_status: 'MERCADORIA SINISTRADA', bearpost_status: 'Problematic'},
    '15': {azul_status: 'EMBALAGEM SINISTRADA', bearpost_status: 'Problematic'},
    '16': {azul_status: 'PEDIDO DE COMPRAS EM DUPLICIDADE', bearpost_status: 'Problematic'},
    '17': {azul_status: 'MERCADORIA FORA DA EMBALAGEM DE ATACADISTA', bearpost_status: 'Problematic'},
    '18': {azul_status: 'MERCADORIAS TROCADAS', bearpost_status: 'Problematic'},
    '19': {azul_status: 'REENTREGA SOLICITADA PELO CLIENTE.', bearpost_status: 'On the way'},
    '20': {azul_status: 'ENTREGA PREJUDICADA POR HORARIO/FALTA DE TEMPO HABIL', bearpost_status: 'On the way'},
    '21': {azul_status: 'ESTABELECIMENTO FECHADO.', bearpost_status: 'On the way'},
    '22': {azul_status: 'REENTREGA SEM COBRANCA DO CLIENTE', bearpost_status: 'On the way'},
    '23': {azul_status: 'EXTRAVIO DE MERCADORIA EM TRANSITO', bearpost_status: 'Problematic'},
    '24': {azul_status: 'MERCADORIA REENTREGUE AO CLIENTE DESTINO', bearpost_status: 'Problematic'},
    '25': {azul_status: 'MERCADORIA DEVOLVIDA AO CLIENTE DE ORIGEM', bearpost_status: 'Returned'},
    '26': {azul_status: 'NOTA FISCAL RETIDA PELA FISCALIZACAO', bearpost_status: 'Problematic'},
    '27': {azul_status: 'ROUBO DE CARGA', bearpost_status: 'Problematic'},
    '28': {azul_status: 'MERCADORIA RETIDA ATE SEGUNDA ORDEM', bearpost_status: 'Problematic'},
    '29': {azul_status: 'CLIENTE RETIRA MERCADORIA NA TRANSPORTADORA', bearpost_status: 'On the way'},
    '30': {azul_status: 'PROBLEMA COM A DOCUMENTACAO (NOTA FISCAL / CTRC)', bearpost_status: 'Problematic'},
    '31': {azul_status: 'ENTREGA COM INDENIZACAO EFETUADA', bearpost_status: 'Problematic'},
    '32': {azul_status: 'FALTA COM SOLICITACAO DE REPOSICAO', bearpost_status: 'On the way'},
    '33': {azul_status: 'FALTA COM BUSCA/RECONFERENCIA', bearpost_status: 'On the way'},
    '34': {azul_status: 'CLIENTE FECHADO PARA BALANCO.', bearpost_status: 'On the way'},
    '35': {azul_status: 'QUANTIDADE DE PRODUTO EM DESACORDO (NOTA FISCAL E/OU PEDIDO)', bearpost_status: 'Problematic'},
    '36': {azul_status: 'BAIXA POR SINISTRO', bearpost_status: 'Problematic'},
    '37': {azul_status: 'BAIXA FISCAL', bearpost_status: 'On the way'},
    '38': {azul_status: 'BAIXA SEM COMPROVANTE (DO AGENTE)', bearpost_status: 'On the way'},
    '41': {azul_status: 'PEDIDO DE COMPRA INCOMPLETO', bearpost_status: 'On the way'},
    '42': {azul_status: 'NOTA FISCAL COM PRODUTOS DE SETORES DIFERENTES', bearpost_status: 'On the way'},
    '43': {azul_status: 'FERIADO LOCAL/NACIONAL', bearpost_status: 'On the way'},
    '45': {azul_status: 'CLIENTE DESTINO ENCERROU ATIVIDADES', bearpost_status: 'Problematic'},
    '46': {azul_status: 'RESPONSAVEL DE RECEBIMENTO AUSENTE', bearpost_status: 'On the way'},
    '47': {azul_status: 'CLIENTE DESTINO EM GREVE', bearpost_status: 'Problematic'},
    '50': {azul_status: 'GREVE NACIONAL (GREVE GERAL)', bearpost_status: 'Problematic'},
    '55': {azul_status: 'LOCAL DE ENTREGA COM RESTRIÇÃO', bearpost_status: 'Problematic'},
    '60': {azul_status: 'ENDEREÇO DE ENTREGA ERRADO', bearpost_status: 'Problematic'},
    '65': {azul_status: 'ENTRAR EM CONTATO COM O COMPRADOR', bearpost_status: 'Problematic'},
    '66': {azul_status: 'TROCA NAO DISPONIVEL', bearpost_status: 'On the way'},
    '68': {azul_status: 'DATA DE ENTREGA DIFERENTE DO PEDIDO', bearpost_status: 'On the way'},
    '69': {azul_status: 'SUBSTITUICAO TRIBUTARIA', bearpost_status: 'On the way'},
    '70': {azul_status: 'SISTEMA FORA DO AR.', bearpost_status: 'On the way'},
    '71': {azul_status: 'CLIENTE DESTINO NAO RECEBE PEDIDO PARCIAL', bearpost_status: 'Problematic'},
    '72': {azul_status: 'CLIENTE DESTINO SO RECEBE PEDIDO PARCIAL', bearpost_status: 'Problematic'},
    '73': {azul_status: 'REDESPACHO SOMENTE COM FRETE PAGO', bearpost_status: 'Problematic'},
    '74': {azul_status: 'FUNCIONARIO NAO AUTORIZADO A RECEBER MERCADORIAS', bearpost_status: 'Problematic'},
    '75': {azul_status: 'MERCADORIA EMBARCADA PARA ROTA INDEVIDA', bearpost_status: 'On the way'},
    '76': {azul_status: 'ESTRADA/ENTRADA DE ACESSO INTERDITADA', bearpost_status: 'On the way'},
    '77': {azul_status: 'CLIENTE DESTINO MUDOU DE ENDERECO', bearpost_status: 'Problematic'},
    '78': {azul_status: 'AVARIA TOTAL', bearpost_status: 'Problematic'},
    '79': {azul_status: 'AVARIA PARCIAL', bearpost_status: 'Problematic'},
    '80': {azul_status: 'EXTRAVIO TOTAL', bearpost_status: 'Problematic'},
    '81': {azul_status: 'EXTRAVIO PARCIAL', bearpost_status: 'Problematic'},
    '82': {azul_status: 'SOBRA DE MERCADORIA SEM NOTA FISCAL', bearpost_status: 'Problematic'},
    '83': {azul_status: 'MERCADORIA EM PODER DA SUFRAMA PARA INTERNACAO', bearpost_status: 'Problematic'},
    '84': {azul_status: 'MERCADORIA RETIRADA PARA CONFERENCIA', bearpost_status: 'Problematic'},
    '85': {azul_status: 'APREENSAO FISCAL DA MERCADORIA', bearpost_status: 'Problematic'},
    '86': {azul_status: 'EXCESSO DE CARGA/PESO', bearpost_status: 'Problematic'},
    '87': {azul_status: 'DESTINATÁRIO EM FÉRIAS COLETIVAS', bearpost_status: 'Problematic'},
    '88': {azul_status: 'RECUSA AGUARDANDO NEGOCIAÇÃO', bearpost_status: 'Problematic'},
    '91': {azul_status: 'ENTREGA PROGRAMADA.', bearpost_status: 'On the way'},
    '92': {azul_status: 'PROBLEMAS FISCAIS', bearpost_status: 'Problematic'},
    '100': {azul_status: 'EMISSAO DO CONHECIMENTO DE TRANSPORTE.', bearpost_status: 'On the way'},
    '104': {azul_status: 'EMISSAO DE MANIFESTO DE SAIDA.', bearpost_status: 'Out for delivery'},
    '106': {azul_status: 'EMISSAO DA LISTAGEM DE ENTREGAS.', bearpost_status: 'On the way'},
    '107': {azul_status: 'CANCELAMENTO DO CONHECIMENTO.', bearpost_status: 'On the way'},
    '108': {azul_status: 'REIMPRESSAO DE CONHECIMENTO.', bearpost_status: 'On the way'},
    '112': {azul_status: 'CARGA RECEBIDA EM VOO FORA DA ROTERIZAÇÃO', bearpost_status: 'On the way'},
    '127': {azul_status: 'UNITIZACAO DA CARGA.', bearpost_status: 'On the way'},
    '128': {azul_status: 'DESUNITIZACAO DA CARGA', bearpost_status: 'On the way'},
    '133': {azul_status: 'SAIDA DO VEICULO', bearpost_status: 'On the way'},
    '134': {azul_status: 'SAIDA DO VOO', bearpost_status: 'On the way'},
    '136': {azul_status: 'CHEGADA DO VEICULO', bearpost_status: 'On the way'},
    '137': {azul_status: 'CHEGADA DO VOO', bearpost_status: 'On the way'},
    '138': {azul_status: 'EMBARQUE DE CARGA NO VOO', bearpost_status: 'On the way'},
    '142': {azul_status: 'CARREGAMENTO DO VEICULO', bearpost_status: 'On the way'},
    '144': {azul_status: 'EM PROCESSO DE CONFERENCIA', bearpost_status: 'On the way'},
    '200': {azul_status: 'POSICIONAMENTO DE CARGA EM LOCATION', bearpost_status: 'On the way'},
    '201': {azul_status: 'CONEXAO IMEDIATA DE VOO.', bearpost_status: 'On the way'},
    '517': {azul_status: 'PASSAGEM PELA FISCALIZACAO', bearpost_status: 'On the way'}
  }

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
    authenticate!
    check_tracking_number(shipment)
    token = settings['token']
    response = connection.get("api/Ocorrencias/Consultar?Token=#{token}&AWB=#{shipment.tracking_number}")
    check_response(response)
    events = response.body.dig("Value", 0, "Ocorrencias")
    delivery_updates = []
    events.each do |event|
      delivery_updates << {
        date: event["DataHora"],
        description: "#{event["Descricao"]} - #{event["UnidadeMunicipio"]}, #{event["UnidadeUF"]}",
        bearpost_macro_status: STATUS_CODES[event["Codigo"][:bearpost_status]
      }
    end
    delivery_updates
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
