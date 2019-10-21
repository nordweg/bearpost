module ApplicationHelper
  def flash_class(level)
    case level
    when 'notice'  then "primary"
    when 'success' then "success"
    when 'error'   then "danger"
    when 'alert'   then "warning"
    end
  end

  def shipment_statuses_for_select
    statuses = []
    Shipment.statuses.each do |status|
      statuses << [ I18n.t(status), status ]
    end
    statuses
  end

  def late_statuses_for_select
    [
      ["Envio", "handling_late"],
      ["Transportadora", "carrier_delivery_late"],
      ["Cliente", "client_delivery_late"]
    ]
  end

  def accounts_for_select
    Account.all.map{|account| [account.name, account.id]}
  end

  def carriers_for_select
    Carriers.all.map{|carrier| [carrier.name, carrier.to_s]}
  end

  def status_label(status)
    right_class = case status
      when "Pending"                then "kt-badge--metal"
      when "Ready for shipping"     then "kt-badge--warning"
      when "On the way"             then "kt-badge--info"
      when "Out for delivery"       then "kt-badge--info"
      when "Delivered"              then "kt-badge--success"
      when "Problematic"            then "kt-badge--danger"
      when "Returned"               then "kt-badge--metal"
      when "Cancelled"              then "kt-badge--metal"
      when "Waiting for pickup"     then "kt-badge--info"
    end
    "<span class='kt-badge #{right_class} kt-badge--inline kt-badge--pill'><nobr>#{ I18n.t(status) }</nobr></span>".html_safe
  end




end
