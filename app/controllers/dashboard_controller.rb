class DashboardController < ApplicationController

  def index
    unless params[:date_range]
      redirect_to dashboard_path(date_range:"#{30.days.ago.strftime("%d/%m/%Y")} - #{Date.today.strftime("%d/%m/%Y")}")
    end
    @shipments = Shipment.filter(params)
    @late_shipments = @shipments.attention_required
    @carriers_pie_chart_data = get_shipments_per_carrier_pie_chart_data(@shipments)
    @shipping_method_pie_chart_data = get_shipping_method_pie_chart_data(@shipments)
    @shipments_per_status = get_shipments_per_status(@shipments)
    @shipments_by_state = get_shipments_per_state(@shipments)
    @average_sla = get_average_sla(@shipments)
    @average_carrier_delivery_days_used = get_average_carrier_delivery_days_used(@shipments)
    @average_client_delivery_days_used = get_average_client_delivery_days_used(@shipments)
    @days_until_delivery = get_days_until_delivery(@shipments)
    @delayed_or_problematic_shipments = Shipment.attention_required
  end

  def get_shipments_per_carrier_pie_chart_data(shipments)
    data = []
    shipments.group(:carrier_class).count.each do |k, v|
      data << [k.constantize.name, v, k]
    end
    data.sort! {|a, b| b[1] <=> a[1]}
    data.unshift(["Transportadora", "Envios", "Carrier"])
  end

  def get_shipping_method_pie_chart_data(shipments)
    data = []
    shipments.group(:shipping_method).count.each do |k, v|
      data << [k, v]
    end
    data.sort! {|a, b| b[1] <=> a[1]}
    data.unshift(["Método de envio", "Envios"])
  end

  def get_shipments_per_status(shipments)
    data = []
    total_shipments = shipments.count
    shipments.all.group(:status).count.each do |status, quantity|
      percentage = (quantity.to_f / total_shipments.to_f) * 100
      data << [ status, quantity, percentage]
    end
    data
  end

  def get_average_sla(shipments)
    shipments.average(:carrier_delivery_days_delayed).to_f.round(1)
  end

  def get_average_carrier_delivery_days_used(shipments)
    shipments.average(:carrier_delivery_days_used).to_f.round(1)
  end

  def get_average_client_delivery_days_used(shipments)
    shipments.average(:client_delivery_days_used).to_f.round(1)
  end

  def get_shipments_per_state(shipments)
    data = [["Estado", "Envios"]]
    total_shipments = shipments.count
    shipments.group(:state).count.each do |state, number|
      data << [state, number]
    end
    data
  end

  def get_days_until_delivery(shipments)
    data = []
    shipments.group(:carrier_delivery_days_used).count.each do |days, number|
      data << [days, number] unless days == nil
    end
    data.sort! {|a, b| a[0] <=> b[0]}
    data.unshift(["Dias", "Envios"])
    data.map {|i| [i[0].to_s + " dias", i[1]]}
  end

end
