module HistoriesHelper
  def tooltip_title(history)
    if history.carrier_status_code
      "ID da transportadora: #{history.carrier_status_code} = #{history.bearpost_status || 'Não mapeado'}"
    end
  end

  def history_icon(history)
    case history.category
    when "carrier"                then "la la-location-arrow"
    when "On the way"             then "flaticon2-delivery-truck"
    when "Out for delivery"       then "la la-home"
    when "Delivered"              then "la la-check-circle"
    when "Problematic"            then "la la-exclamation-triangle"
    when "Returned"               then "la la-mail-reply"
    when "Cancelled"              then "la la-close"
    when "Waiting for pickup"     then "la la-building"
    when "New"                    then "la la-star"
    when "Pending"                then "la la-star-half-o"
    when "Ready for shipping"     then "la la-clock-o"
    when nil                      then "metal"
    end
  end

  def icon_color(history)
    case history.category
    when "carrier"                then "primary"
    when "Pending"                then "metal"
    when "Ready for shipping"     then "warning"
    when "On the way"             then "primary"
    when "Out for delivery"       then "primary"
    when "Delivered"              then "success"
    when "Problematic"            then "danger"
    when "Returned"               then "metal"
    when "Cancelled"              then "metal"
    when "Waiting for pickup"     then "primary"
    when "New"                    then "warning"
    when nil                      then "metal"
    end
  end
end
