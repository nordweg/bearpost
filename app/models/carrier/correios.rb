class Carrier::Correios < Carrier
  cattr_reader :name
  @@name = "Correios"

  TEST_URL = "https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl"
  LIVE_URL = "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl"
  SERVICES = ['PAC','SEDEX']

  ID_SERVICOS = {
    '40010' => "SEDEX sem contrato",
    '40045' => "SEDEX a Cobrar, sem contrato",
    '40126' => "SEDEX a Cobrar, com contrato",
    '40215' => "SEDEX 10, sem contrato",
    '40290' => "SEDEX Hoje, sem contrato",
    '40096' => "SEDEX com contrato",
    '40436' => "SEDEX com contrato",
    '40444' => "SEDEX com contrato",
    '40568' => "SEDEX com contrato",
    '40606' => "SEDEX com contrato",
    '41106' => "PAC sem contrato",
    '41211 / 41068' => "PAC com contrato",
    '81019' => "e-SEDEX, com contrato",
    '81027' => "e-SEDEX Prioritário, com contrato",
    '81035' => "e-SEDEX Express, com contrato",
    '81868' => "(Grupo 1) e-SEDEX, com contrato",
    '81833' => "(Grupo 2 ) e-SEDEX, com contrato",
    '81850' => "(Grupo 3 ) e-SEDEX, com contrato",
  }


  def self.shipping_methods
    ['PAC','SEDEX']
  end

  def authenticate!
    true
  end

  def valid_credentials?
    true
  end

  def self.settings
    [
      :sigep_user,
      :sigep_password,
      :tracking_user,
      :tracking_password,
      :administrative_code,
      :contract,
      :posting_card,
      :cnpj,
      :pac_label_minimum_quantity,
      :pac_label_reorder_quantity,
      :sedex_label_minimum_quantity,
      :sedex_label_reorder_quantity,
    ]
  end

  def self.tracking_url
    "https://rastreamentocorreios.info/consulta/{tracking}"
  end

  def get_tracking_number(shipment)
    account         = shipment.account
    shipping_method = shipment.shipping_method

    check_tracking_number_availability(account,shipping_method)

    current_range = settings['shipping_methods'][shipping_method]['ranges'].first
    prefix        = current_range['prefix']
    number        = current_range['next_number']
    sufix         = current_range['sufix']
    verification_digit = get_verification_digit(number)
    tracking_number    = "#{prefix}#{number}#{verification_digit}#{sufix}"

    if current_range['next_number'] + 1 > current_range['last_number']
      settings['shipping_methods'][shipping_method]['ranges'].delete(current_range)
    else
      current_range['next_number'] += 1
    end
    carrier_setting.save

    tracking_number
  end

  def prepare_label(shipment)
    if shipment.tracking_number.blank?
      shipment.tracking_number = get_tracking_number(shipment)
      shipment.save
    end
  end

  def get_delivery_updates(shipment)
    message = {
      "usuario" => settings[:tracking_user],
      "senha" => settings[:tracking_password],
      "tipo" => "L",
      "resultado" => "T",
      "lingua" => "101",
      "objetos" => shipment.tracking_number
    }
    response = tracking_connection.call(:busca_eventos, message:message)
    events = response.body.dig(:busca_eventos_response,:return,:objeto,:evento)
    error = response.body.dig(:busca_eventos_response,:return,:objeto,:erro)
    raise Exception.new("Correios: #{error}") if error
    delivery_updates = []
    events.each do |event|
      delivery_updates << {
        date: "#{event[:data]} #{event[:hora]}",
        description: "#{event[:descricao]} em #{event[:cidade]}, #{event[:uf]}. #{event[:local]}",
        bearpost_macro_status: 'Entregue'
      }
    end
    delivery_updates
  end

  # private

  def check_tracking_number_availability(account,shipping_method)
    settings        = self.settings['shipping_methods'][shipping_method]
    ranges          = settings['ranges'] || []

    if count_available_labels(shipping_method) < settings['label_minimum_quantity'].to_i
      save_new_range(account,shipping_method)
    end
  end

  def save_new_range(shipping_method)
    ranges_array = get_ranges_from_correios(shipping_method)
    next_number  = ranges_array[0][2..9]
    last_number  = ranges_array[-1][2..9]
    prefix       = ranges_array[0][0..1]
    sufix        = ranges_array[0][-2..-1]
    range_hash   = {
      "created_at":  DateTime.now,
      "prefix":      prefix,
      "next_number": next_number.to_i,
      "last_number": last_number.to_i,
      "sufix":       sufix,
    }
    ranges = settings['shipping_methods'][shipping_method]['ranges'] || []
    ranges << range_hash
    settings['shipping_methods'][shipping_method]['ranges'] = ranges
    carrier_setting.save
  end

  def count_available_labels(shipping_method)
    settings = self.settings['shipping_methods'][shipping_method]
    return 0 if settings['ranges'].blank?
    total = 0
    settings['ranges'].each do |range|
      total += range['last_number'] - range['next_number'] + 1
    end
    total
  end

  def check_posting_card(account)
    message = {
      "usuario" => settings[:sigep_user],
      "senha" => settings[:sigep_password],
      "numeroCartaoPostagem" =>  settings[:posting_card],
    }
    response = client(account).call(:get_status_cartao_postagem, message:message)

    response.body.dig(:get_status_cartao_postagem_response,:return)
  end

  def get_ranges_from_correios(shipping_method)
    reorder_quantity = settings.dig('shipping_methods',shipping_method,'label_reorder_quantity')
    reorder_quantity = '10' if reorder_quantity.blank?

    message = {
      "tipoDestinatario" =>  "C",
      "identificador" => settings[:cnpj],
      "idServico" => "124884",
      "qtdEtiquetas" => reorder_quantity,
      "usuario" => settings[:sigep_user],
      "senha" => settings[:sigep_password],
    }
    response = connection.call(:solicita_etiquetas, message:message)
    ranges   = response.body.dig(:solicita_etiquetas_response,:return)
    ranges.split(',')
  end

  def create_plp(shipments)
    account  = shipments.first.account
    user     = settings[:sigep_user]
    password = settings[:sigep_password]
    posting_card = settings[:posting_card]
    xml = build_xml(shipments)
    labels = []
    shipments.each do |shipment|
      labels << shipment.tracking_number[0..9] + shipment.tracking_number[-2..-1]
    end
    message = {
      "xml" =>  xml,
      "idPlpCliente" => 123123,
      "cartaoPostagem" => posting_card,
      "listaEtiquetas" => labels,
      "usuario" => user,
      "senha" => password,
    }
    client(account).call(:fecha_plp_varios_servicos, message:message)
  end

  def get_plp_xml(account,plp_number)
    message = {
      "idPlpMaster" => plp_number,
      "usuario" => settings[:sigep_user],
      "senha" => settings[:sigep_password],
    }
    client(account).call(:solicita_xml_plp, message:message)
  end

  def send_to_carrier(shipments)
    response = []
    begin
      correios_response = create_plp(shipments)
      plp_number = correios_response.body.dig(:fecha_plp_varios_servicos_response,:return)
      message = "Enviado na PLP #{plp_number}"
      shipments.each do |shipment|
        settings = shipment.settings
        settings['plp'] = plp_number
        shipment.update(settings:settings,sent_to_carrier:true)
        response << {
          shipment: shipment,
          success: shipment.sent_to_carrier,
          message: message
        }
      end
    rescue Exception => e
      shipments.each do |shipment|
        response << {
          shipment: shipment,
          success: shipment.sent_to_carrier,
          message: e.message
        }
      end
    end
    response
  end

  def build_xml(shipments)
    account  = shipments.first.account
    posting_card = settings[:posting_card]
    contract = settings[:contract]
    administrative_code = settings[:administrative_code]

    builder = Nokogiri::XML::Builder.new do |xml|
      xml.correioslog {
        xml.tipo_arquivo 'Postagem'
        xml.versao_arquivo '2.3'
        xml.plp {
          xml.id_plp
          xml.valor_global
          xml.mcu_unidade_postagem
          xml.nome_unidade_postagem
          xml.cartao_postagem posting_card
        }
        xml.remetente {
          xml.numero_contrato contract
          xml.numero_diretoria get_numero_diretoria(account.state)
          xml.codigo_administrativo administrative_code
          xml.nome_remetente account.name
          xml.logradouro_remetente account.street
          xml.numero_remetente account.number
          xml.complemento_remetente account.complement
          xml.bairro_remetente account.neighborhood
          xml.cep_remetente account.zip
          xml.cidade_remetente account.city
          xml.uf_remetente account.state
          xml.telefone_remetente account.phone
          xml.email_remetente account.email
        }
        xml.forma_pagamento
        shipments.each do |shipment|
          package = shipment.packages.last
          xml.objeto_postal {
            xml.numero_etiqueta shipment.tracking_number[0..9] + shipment.tracking_number[-2..-1]
            xml.codigo_objeto_cliente
            xml.codigo_servico_postagem '41106'
            xml.cubagem package.heigth * package.width * package.depth
            xml.peso package.weight
            xml.rt2
            xml.destinatario {
              xml.nome_destinatario shipment.full_name
              xml.telefone_destinatario shipment.phone
              xml.email_destinatario shipment.email
              xml.logradouro_destinatario shipment.street
              xml.complemento_destinatario shipment.complement
              xml.numero_end_destinatario shipment.number
            }
            xml.nacional {
              xml.bairro_destinatario shipment.neighborhood
              xml.cidade_destinatario shipment.city
              xml.uf_destinatario shipment.state
              xml.cep_destinatario shipment.zip
              xml.numero_nota_fiscal shipment.invoice_number
              xml.serie_nota_fiscal shipment.invoice_series
              xml.natureza_nota_fiscal
            }
            xml.servico_adicional {
              xml.codigo_servico_adicional '025'
            }
            xml.dimensao_objeto {
              xml.tipo_objeto '002'
              xml.dimensao_altura package.heigth
              xml.dimensao_largura package.width
              xml.dimensao_comprimento package.depth
              xml.dimensao_diametro 0
            }
          }
        end
      }
    end
    builder.to_xml
  end

  def get_numero_diretoria(state)
    hash = {
      'ACRE'=> '03',
      'ALAGOAS'=> '04',
      'AMAZONAS'=> '06',
      'AMAPÁ'=> '05',
      'BAHIA'=> '08',
      'BRASÍLIA'=> '10',
      'CEARÁ'=> '12',
      'ESPIRITO SANTO'=> '14',
      'GOIÁS'=> '16',
      'MARANHÃO'=> '18',
      'MINAS GERAIS'=> '20',
      'MATO GROSSO DO SUL'=> '22',
      'MATO GROSSO'=> '24',
      'PARÁ'=> '28',
      'PARAÍBA'=> '30',
      'PERNAMBUCO'=> '32',
      'PIAUÍ'=> '34',
      'PARANÁ'=> '36',
      'RIO DE JANEIRO'=> '50',
      'RIO GRANDE DO NORTE'=> '60',
      'RONDONIA'=> '26',
      'RORAIMA'=> '65',
      'RIO GRANDE DO SUL'=> '64',
      'SANTA CATARINA'=> '68',
      'SERGIPE'=> '70',
      'SÃO PAULO INTERIOR'=> '74',
      'SÃO PAULO'=> '72',
      'TOCANTINS'=> '75'
    }
    hash.find {|key,value| key.downcase.include?(state.downcase)}[1]
  end

  def busca_cliente(account)
    settings = CarrierSetting.carrier(Carrier::Correios).settings
    user = settings[:sigep_user]
    password = settings[:sigep_password]
    posting_card = settings[:posting_card]
    contract = settings[:contract]

    message = {
      "idContrato" => contract,
      "idCartaoPostagem" => posting_card,
      "usuario" => user,
      "senha" => password,
    }

    client(account).call(:busca_cliente, message:message)
  end

  def consulta_cep(account)
    connection.call(:consulta_cep, message:{'cep'=>'70002900'})
  end

  def verify_service_availability
    message = {
      "codAdministrativo" => settings[:administrative_code],
      "numeroServico" => "04162",
      "cepOrigem" => "95166000",
      "cepDestino" => "95150000",
      "usuario" => settings[:sigep_user],
      "senha" => settings[:sigep_password],
    }
    connection.call(:verifica_disponibilidade_servico, message:message)
  end

  def connection
    url = test_mode? ? TEST_URL : LIVE_URL
    user = settings.dig(:sigep_user)
    password = settings.dig(:sigep_password)
    Savon.client(
      wsdl: url,
      basic_auth: [user,password],
      headers: { 'SOAPAction' => '' }
    )
  end

  def tracking_connection
    Savon.client(
      wsdl: "http://webservice.correios.com.br/service/rastro/Rastro.wsdl",
      headers: { 'SOAPAction' => '' }
    )
  end

  def get_verification_digit(number)
    multipliers = [8, 6, 4, 2, 3, 5, 9, 7]
    total = 0

    number.to_s.chars.map(&:to_i).each_with_index do |number,index|
      total += number * multipliers[index]
    end

    remainder = total % 11

    if remainder == 0
      verification_digit = 5;
    elsif remainder == 1
      verification_digit = 0;
    else
      verification_digit = 11 - remainder
    end

    verification_digit
  end
end
