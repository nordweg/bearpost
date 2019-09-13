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
