module ApplicationHelper
  def flash_class(level)
    case level
    when 'notice'  then "primary"
    when 'success' then "success"
    when 'error'   then "danger"
    when 'alert'   then "warning"
    end
  end

  def status_selector
    [
      ['Todos', nil],
      ['Pendente','pending'],
      ['Pronto para envio','ready'],
      ['Enviado','shipped'],
      ['Cancelado','cancelled']
    ]
  end

  def carrier_selector
    [['Todas',nil]] + Rails.configuration.carriers.map{|carrier| [carrier.name, carrier.to_s]}
  end
end
