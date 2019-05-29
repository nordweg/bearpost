class Carrier::Correios < Carrier
  class << self
    def settings
      [
        'Usuário',
        'Senha',
        'Código Administrativo',
        'Contrato',
        'Codigo Serviço',
        'Cartão',
        'CNPJ',
      ]
    end

    def tracking_url
      "https://www2.correios.com.br/sistemas/rastreamento/"
    end

    def shipping_methods
      {
        'PAC': { carrier_service_id: 1 },
        'Sedex': { carrier_service_id: 2 },
        'Sedex20': { carrier_service_id: 3 },
      }
    end

    def create_label(package)
      etiquetas         = solicita_etiquetas
      etiqueta          = etiquetas.last
      etiqueta_completa = adiciona_digito_verificador(etiqueta)
    end

    private

    def check_posting_card
      message = {
        "numeroCartaoPostagem" =>  "0067599079",
        "usuario" => "sigep",
        "senha" => "n5f9t8",
      }
      response = client.call(:get_status_cartao_postagem, message:message)

      response.body.dig(:get_status_cartao_postagem_response,:return)
    end

    def solicita_etiquetas
      message = {
        "tipoDestinatario" =>  "C",
        "identificador" => "34028316000103",
        "idServico" => "124849",
        "qtdEtiquetas" => "1",
        "usuario" => "sigep",
        "senha" => "n5f9t8",
      }

      response = client.call(:solicita_etiquetas, message:message)
      range = response.body.dig(:solicita_etiquetas_response,:return)
      range.split(',')
    end

    def client
      Savon.client(
        wsdl: "https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl",
        basic_auth: ["sigep", "n5f9t8"],
        headers: { 'SOAPAction' => '' }
      )
    end

    def adiciona_digito_verificador(etiqueta)
      prefixo = etiqueta[0..1]
      numero  = etiqueta[2..9]
      sufixo  = etiqueta[11..12]

      multiplicadores = [8, 6, 4, 2, 3, 5, 9, 7]
      soma = 0

      numero.chars.map(&:to_i).each_with_index do |number,index|
        soma += number * multiplicadores[index]
      end

      resto = soma % 11

      if resto == 0
        dv = 5;
      elsif resto == 1
        dv = 0;
      else
        dv = 11 - resto
      end
      dv = dv.to_s

      prefixo + numero + dv + sufixo
    end
  end
end
