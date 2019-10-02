class DashboardController < ApplicationController

  def index
    @shipments = Shipment.all
    # @shipments = Carrier::Azul.shipments
    # @shipments = Shipment.where(carrier_delivery_late: true)

    @late_shipments = @shipments.attention_required
    @carriers_pie_chart_data = get_shipments_per_carrier_pie_chart_data(@shipments)
    @shipping_method_pie_chart_data = get_shipping_method_pie_chart_data(@shipments)
    @shipments_per_status = get_shipments_per_status(@shipments)
    @shipments_by_state = get_shipments_per_state(@shipments)
  end

  def get_shipments_per_carrier_pie_chart_data(shipments)
    data = []
    shipments.group(:carrier_class).count.each do |k, v|
      data << [k.constantize.name, v]
    end
    data.sort! {|a, b| b[1] <=> a[1]}
    data.unshift(["Transportadora", "Envios"])
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
    total_shipments = Shipment.all.count
    shipments.all.group(:status).count.each do |status, quantity|
      percentage = (quantity.to_f / total_shipments.to_f) * 100
      data << [ I18n.t(status), quantity, percentage]
    end
    data
  end

  def get_average_sla(carrier)
    carrier.shipments.average(:carrier_delivery_days_delayed).to_f
  end

  def get_average_delivery_days_used
    carrier.shipments.average(:carrier_delivery_days_used).to_f
  end

  def get_shipments_per_state(shipments)
    data = [["Estado", "Envios"]]
    total_shipments = Shipment.all.count
    shipments.group(:state).count.each do |state, number|
      data << [state, number]
    end
    data
  end

end
