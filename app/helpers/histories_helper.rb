module HistoriesHelper
  def tooltip_title(history)
    if history.carrier_status_code
      "ID da transportadora: #{history.carrier_status_code} = #{history.bearpost_status || 'Não mapeado'}"
    end
  end

  def history_icon(history)
    case history.category
    when 'status'  then "la la-rotate-right"
    when 'carrier' then "flaticon2-delivery-truck"
    end
  end

  def icon_color(history)
    case history.bearpost_status
    when "Pending"                then "metal"
    when "Ready for shipping"     then "warning"
    when "On the way"             then "primary"
    when "Out for delivery"       then "primary"
    when "Delivered"              then "success"
    when "Problematic"            then "danger"
    when "Returned"               then "metal"
    when "Cancelled"              then "metal"
    when "Waiting for pickup"     then "primary"
    when nil                      then "metal"
    end
  end
end
