class StatusUpdates
{
  :ready_for_delivery
  :in_transit
  :cancelled
  :check_delivery_problem
  :client_action_required
  :check_delayed_delivery
  :delivery_failed
  :delivered
  :out_for_delivery
}
end

array = [
  {types:['BDE','BDI','BDR'], status: 0, description: 'Objeto entregue ao destinatário', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 1, description: 'Objeto entregue ao destinatário', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 2, description: 'A entrega não pode ser efetuada - Carteiro não atendido', macro_status: :client_action_required},
  {types:['BDE','BDI','BDR'], status: 3, description: 'Remetente não retirou objeto na Unidade dos Correios', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 4, description: 'A entrega não pode ser efetuada - Cliente recusouse a receber', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 5, description: 'A entrega não pode ser efetuada', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 6, description: 'A entrega não pode ser efetuada - Cliente desconhecido no local', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 7, description: 'A entrega não pode ser efetuada - Endereço incorreto', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 8, description: 'A entrega não pode ser efetuada - Endereço incorreto', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 9, description: 'Objeto não localizado', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 10, description: 'A entrega não pode ser efetuada - Cliente mudou-se', macro_status: :delivered},
  {types:['BDE','BDI','BDR'], status: 12, description: 'Remetente não retirou objeto na Unidade dos Correios', macro_status: :delivered},
]

status_types = {
  ['BDE','BDI','BDR'] => {
    status: 0, macro_status: :delivered # Objeto entregue ao destinatário
    status: 1, macro_status: :delivered # Objeto entregue ao destinatário
    status: 2, macro_status: :delivered # Objeto entregue ao destinatário
  }
}


Shipment.where(status:"Delivered",delivered_at:nil).each do |shipment|
  shipment.histories.where(category:"carrier").delete_all
  shipment.update(status:"On the way")
end
CarrierSyncronizer.update_all_shipments_delivery_status


errors = []
Spree::Shipment.shipped.where("created_at > ?", Date.parse("01/09/2019").beginning_of_day).each do |shipment|
  params = {
    shipment: {
      shipped_at: shipment.shipped_at
    }
  }
  begin
    Bearpost::Shipment.update(shipment,params)
    p "Envio #{shipment.number} OK"
  rescue Exception => e
    errors << [shipment.order.number, e.message]
  end
end

user.notifications.create(description:"Olha esse envio!",path:"/shipments/858",category:"shipment")

errors = []
History.where(category:'status').each do |history|
  description = history.description
  category = case
  when description.include?("para Enviado")
    "On the way"
  when description.include?("para Pendente")
    "Pending"
  when description.include?("para Pronto para envio")
    "Ready for shipping"
  when description.include?("para A caminho")
    "On the way"
  when description.include?("para Saiu para entrega")
    "Out for delivery"
  when description.include?("para Entregue")
    "Delivered"
  when description.include?("para Com problemas")
    "Problematic"
  when description.include?("para Retornado")
    "Returned"
  when description.include?("para Cancelado")
    "Cancelled"
  when description.include?("para Aguardando retirada")
    "Waiting for pickup"
  when description.include?("Pedido criado")
    "New"
  else
    errors << history
    nil
  end
  history.update(category:category) if category
end

# Update shipped_at according to created_at (when they forget to set shipped_at)
Shipment.where("shipped_at > ?", 2.days.ago).each do |shipment|
  if shipment.shipped_at.to_date != shipment.created_at.to_date
    shipment.update(shipped_at:shipment.created_at + 1.hour)
  end
end


require 'benchmark'

n = 10_000
Benchmark.bm do |benchmark|
  benchmark.report("Pluck") do
    n.times do
      Account.all.pluck(:name, :id)
    end
  end

  benchmark.report("Map") do
    n.times do
      Account.all.map{|account| [account.name, account.id]}
    end
  end
end

# delete_correios_ranges

shipment = Shipment.find(2836) # Emme shipment
carrier_setting = shipment.carrier_settings
Carrier::Correios::SERVICES.each do |shipping_method|
  carrier_setting.settings[shipping_method]['ranges'] = []
end
carrier_setting.save
