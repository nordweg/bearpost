class Carrier
  class << self

    def id
      name.demodulize.downcase
    end

    def display_name
      id.titleize
    end

    def settings_field
      "#{id}_settings"
    end

    def shipment_menu_links
      []
    end

    def settings
      {
        'general': [],
        'shipping_methods': {}
      }.with_indifferent_access
    end

    def shipping_methods
      settings[:shipping_methods].keys
    end

    def tracking_url
      raise ::NotImplementedError, 'You must implement tracking_url method for this carrier.'
    end

  end
end
