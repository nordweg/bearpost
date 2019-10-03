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
end
