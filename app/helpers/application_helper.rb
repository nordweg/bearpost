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

  def status_label(status)
    class_list = {
      'pending' => 'kt-badge--metal',
      'ready' =>'kt-badge--brand',
      'shipped' => 'kt-badge--success',
      'canceled' => 'kt-badge--warning'
    }
    right_class = class_list[status] || 'kt-badge--metal'
    "<span class='kt-badge #{right_class} kt-badge--inline kt-badge--pill'>#{ I18n.t(status) }</span>".html_safe
  end


end
