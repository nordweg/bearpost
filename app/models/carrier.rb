class Carrier
  attr_reader   :test_mode
  alias_method  :test_mode?, :test_mode
  attr_accessor :carrier_setting, :settings

  TEST_URL = ""
  LIVE_URL = ""
  SERVICES = []

  def initialize(carrier_setting, test_mode = false)
    @carrier_setting = carrier_setting
    @test_mode = test_mode
  end

  # Define an array of general settings for the carrier, eg.
  # ['username','password','posting_card_number']
  def general_settings
    raise ::NotImplementedError, 'You must implement general_settings method for this carrier.'
  end

  # Validate credentials with a call to the API.
  # By default this just does a `find_rates` call with the origin and destination both as
  # the carrier's default_location. Override to provide alternate functionality, such as
  # checking for `test_mode` to use test servers, etc.
  # @return [Boolean] Should return `true` if the provided credentials proved to work,
  #   `false` otherswise.

  def valid_credentials?
    location = self.class.default_location
    find_rates(location, location, Package.new(100, [5, 15, 30]), :test => test_mode)
  rescue
    false
  else
    true
  end

  # should return an array of DeliveryUpdate objects
  def get_delivery_updates(shipment)
    raise ::NotImplementedError, "#get_delivery_updates is not implemented for #{self.class.name}"
  end

  def self.tracking_url
    raise ::NotImplementedError, 'You must implement tracking_url method for this carrier.'
  end

  # This method should respond with the an array of hashes, including the shipment,
  # a boolean stating if the sync was successful, and any message (error or success) from the result of the process.
  # It receives an array of shipments it should sync.
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
  def transmit_shipments(shipments)
    raise ::NotImplementedError, 'You must implement sync_shipments method for this carrier.'
  end

  def self.shipments
    Shipment.where(carrier_class:self.to_s)
  end

  # This method should return a tracking number for the shipment, as a string.
  def get_tracking_number(shipment)
    raise ::NotImplementedError, "#get_tracking_number is not implemented for #{self.class.name}"
  end

  # If any, all the hooks that are required before a label should be set here.
  # This method is optional
  def prepare_label(shipment)
  end

  def shipment_menu_links
    []
  end

  # Sets which view should be used in carrier settings. Will use views/carriers/_general_settings as default or
  # overwrite if you want to use a personalized view instead.
  def self.custom_settings_view # REFACTOR > RENAME TO
    'general_settings'
  end

end
