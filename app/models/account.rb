class Account < ApplicationRecord
  default_scope { order(name: :asc) }

  has_many :shipments
  has_many :carrier_settings

  def selected_shipping_methods(carrier)
    carrier.settings['shipping_methods'].map { |k,v| k }
  end

  def carrier_setting_for(carrier)
    carrier_settings.find_by(carrier_class: carrier.to_s)
  end
end
