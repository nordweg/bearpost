class Carrier
  class << self
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

    def send_to_carrier(shipments)
      # This method should respond with the an array of hashes, including the shipment,
      # a boolean stating if the sync was successful, and any message (error or success) from the result of the process.
      # eg:
      # [
      #   {
      #     shipment: shipment
      #     success: false
      #     message: 'Package size is not valid'
      #   },
      #   {
      #     shipment: shipment,
      #     success: true,
      #     message: 'Envio recebido com sucesso'
      #   }
      # ]
      raise ::NotImplementedError, 'You must implement send_to_carrier method for this carrier.'
    end

    def get_tracking_number(shipment)
      # This method should return a tracking number for the shipment, as a string.
    end

    def prepare_label(shipment)
      # If any, all the hooks that are required before a label should be set here.
      # This method is optional
    end

    def shipment_menu_links
      []
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
      shipping_method_settings.keys
    end
  end
end
