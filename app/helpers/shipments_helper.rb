module ShipmentsHelper
  def delivery_icon(shipment = nil, step1 = nil)
    return nil unless shipment && step1
    late = nil
    realized = nil

    case step1
    when "handling"
      late = shipment.handling_late?
      realized = shipment.shipped_at?
    when "carrier_delivery"
      late = shipment.carrier_delivery_late
      realized = shipment.delivered_at?
    when "client_delivery"
      late = shipment.client_delivery_late
      realized = shipment.delivered_at?
    else
      return "Step não reconhecido para ícone"
    end

    if late
      icon = "<i style='font-size: 22px;' class='la la-exclamation-circle kt-font-warning'></i>".html_safe
    elsif realized
      icon = "<i style='font-size: 22px;' class='la la-check-circle kt-font-info'></i>".html_safe
    else
      icon = nil
    end
  end

  def step_label(shipment, step)
    case step
    when "handling"
      late = shipment.handling_late?
      on_time = !late && shipment.shipped_at?
    when "carrier_delivery"
      late = shipment.carrier_delivery_late
      on_time = !late && shipment.delivered_at?
    when "client_delivery"
      late = shipment.client_delivery_late
      on_time = !late && shipment.delivered_at?
    end

    if late
      "<span class='kt-badge kt-badge--inline kt-badge--pill kt-badge--danger'>#{ I18n.t(step, scope: :abbr) }</span>".html_safe
    elsif on_time
      "<span class='kt-badge kt-badge--inline kt-badge--pill kt-badge--metal'>#{ I18n.t(step, scope: :abbr) }</span>".html_safe
    else # Pending
      "<span class='kt-badge kt-badge--inline kt-badge--pill kt-badge--info'>#{ I18n.t(step, scope: :abbr) }</span>".html_safe
    end
  end

  def expected_shipping_info(shipment)
    html_content = ""
    if shipment.shipping_due_at
      html_content += l(shipment.shipping_due_at, format: :week_day) + "<br>" if shipment.shipping_due_at
      html_content += shipment.handling_days_planned.to_s + " dias úteis"
    else
      html_content += "Aguardando aprovação"
    end
    html_content.html_safe
  end

  def realized_shipping_info(shipment)
    html_content = ""
    if shipment.shipped_at
      html_content += l(shipment.shipped_at, format: :week_day_with_time) + "<br>" if shipment.shipped_at
      html_content += shipment.handling_days_used.to_s + " dias úteis"
    else
      html_content += "Aguardando envio"
    end
    html_content.html_safe
  end

  def expected_carrier_delivery_info(shipment)
    html_content = ""
    if shipment.carrier_delivery_due_at
      html_content += l(shipment.carrier_delivery_due_at, format: :week_day) + "<br>" if shipment.carrier_delivery_due_at
      html_content += shipment.carrier_delivery_days_planned.to_s + " dias úteis"
    else
      html_content += "Aguardando envio"
    end
    html_content.html_safe
  end

  def realized_carrier_delivery_info(shipment)
    html_content = ""
    if shipment.delivered_at
      html_content += l(shipment.delivered_at, format: :week_day_with_time) + "<br>" if shipment.delivered_at
      html_content += shipment.carrier_delivery_days_used.to_s + " dias úteis"
    else
      html_content += "Aguardando entrega"
    end
    html_content.html_safe
  end

  def expected_client_delivery_info(shipment)
    html_content = ""
    if shipment.approved_at
      html_content += l(@shipment.client_delivery_due_at, format: :week_day) + "<br>" if @shipment.client_delivery_due_at
      html_content += @shipment.client_delivery_days_planned.to_s + " dias úteis"
    else
      html_content += "Aguardando envio"
    end
    html_content.html_safe
  end

  def realized_client_delivery_info(shipment)
    html_content = ""
    if shipment.delivered_at
      html_content += l(@shipment.delivered_at, format: :week_day_with_time ) + "<br>" if @shipment.delivered_at
      html_content += @shipment.client_delivery_days_used.to_s + " dias úteis"
    else
      html_content += "Aguardando entrega"
    end
    html_content.html_safe
  end

  def state_name_from_abbr(abbr)
    {
      "AC" => "Acre",
      "AL" => "Alagoas",
      "AP" => "Amapá",
      "AM" => "Amazonas",
      "BA" => "Bahia",
      "CE" => "Ceará",
      "DF" => "Distrito Federal",
      "ES" => "Espírito Santo",
      "GO" => "Goiás",
      "MA" => "Maranhão",
      "MT" => "Mato Grosso",
      "MS" => "Mato Grosso do Sul",
      "MG" => "Minas Gerais",
      "PA" => "Pará",
      "PB" => "Paraíba",
      "PR" => "Paraná",
      "PE" => "Pernambuco",
      "PI" => "Piauí",
      "RJ" => "Rio de Janeiro",
      "RN" => "Rio Grande do Norte",
      "RS" => "Rio Grande do Sul",
      "RO" => "Rondônia",
      "RR" => "Roraima",
      "SC" => "Santa Catarina",
      "SP" => "São Paulo",
      "SE" => "Sergipe",
      "TO" => "Tocantins"
    }[abbr]
  end
end
