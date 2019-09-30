module ShipmentsHelper
  def delivery_icon(days_delayed = nil)
    return nil unless days_delayed
    if days_delayed <= 0
      "<i style='font-size: 20px;' class='fas fa-check-circle kt-font-info'></i>".html_safe
    else
      "<i style='font-size: 20px;' class='fas fa-exclamation-circle kt-font-warning'></i>".html_safe
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
      html_content += l(shipment.carrier_delivery_due_at, format: :week_day_with_time) + "<br>" if shipment.carrier_delivery_due_at
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
