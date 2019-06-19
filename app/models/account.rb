class Account < ApplicationRecord
  default_scope { order(name: :asc) }

  has_many :shipments

  def selected_shipping_methods(carrier)
    # selected_shipping_methods = []
    # self.send(carrier.settings_field)['selected_shipping_methods'].each do |shipping_method, value|
    #   selected_shipping_methods << carrier.shipping_methods.slice(shipping_method.to_sym) if value == '1'
    # end
    # selected_shipping_methods
    # self.send(carrier.settings_field)['shipping_methods'].map {|k,v| k}
    carrier.settings['shipping_methods'].map { |k,v| k }
  end
end
