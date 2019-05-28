class Carrier::Correios < Carrier
  def self.settings
    ['Usuário','Senha','Código Administrativo','Contrato', 'Codigo Serviço', 'Cartão', 'CNPJ']
  end

  def self.tracking_url
    "codigo dos correios"
  end

  def self.shipping_methods
    {
      'PAC': { carrier_service_id: 1 },
      'Sedex': { carrier_service_id: 2 },
      'Sedex20': { carrier_service_id: 3 },
    }
  end

  def create_shipping_label(shipment)

  end
  
end
