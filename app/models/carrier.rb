class Carrier
  class << self
    def shipment_menu_links
      []
    end

    def general_settings
      # Define an array of general settings for the carrier, eg.
      # ['username','password','posting_card_number']
      raise ::NotImplementedError, 'You must implement general_settings method for this carrier.'
    end

    def shipping_method_settings
      # Define a hash of available shipping methods and settings required, eg.
      # {
      #   'PAC': [
      #     'carrier_service_id',
      #     'label_minimum_quantity',
      #     'label_reorder_quantity',
      #   ],
      #   'Sedex': [
      #     'carrier_service_id',
      #     'label_minimum_quantity',
      #     'label_reorder_quantity'
      #   ]
      # }
      raise ::NotImplementedError, 'You must implement shipping_method_settings method for this carrier.'
    end

    def tracking_url
      raise ::NotImplementedError, 'You must implement tracking_url method for this carrier.'
    end

    def id
      name.demodulize.downcase
    end

    def display_name
      id.titleize
    end

    def settings_field
      "#{id}_settings"
    end

    def settings
      {
        'general': general_settings,
        'shipping_methods': shipping_methods
      }.with_indifferent_access
    end

    def shipping_methods
      settings[:shipping_methods].keys
    end
  end
end
