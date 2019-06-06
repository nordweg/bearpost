module CarriersHelper
  def carrier_from_id(carrier_id)
    "Carrier::#{carrier_id.titleize}".constantize
  end
end
