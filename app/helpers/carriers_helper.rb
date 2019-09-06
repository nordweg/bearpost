module CarriersHelper
  def carrier_from_id(carrier_id)
    "Carrier::#{carrier_id.titleize}".constantize rescue nil
  end
end

@carrier = shipment.carrier."Carrier::Azul".constantize.name
