class Carrier
  attr_reader   :test_mode
  alias_method  :test_mode?, :test_mode
  attr_accessor :carrier_setting, :settings

  ## GENERAL DEFINITIONS ##
  # Define Carrier related constants here
  TEST_URL = ""
  LIVE_URL = ""
  SERVICES = []
  TRACKING_URL = ""

  ## DEFAULT BEHAVIOR ##
  # This is the behavior shared by all carriers. No need to change it.

  def initialize(carrier_setting, test_mode = false)
    @carrier_setting = carrier_setting
    @test_mode = test_mode
  end

  def self.shipments
    Shipment.where(carrier_class:self.to_s)
  end

  ## REQUIRED METHODS ##
  # These are the mandatory default methods that are going to be called by the core Bearpost application.
  # You should overwrite each of these methods.

  # Define an array of general settings for the carrier
  def self.settings
    raise ::NotImplementedError, "#settings is not implemented for #{self.class.name}"
    example = [
      {field:'email',    type:'text'},
      {field:'password', type:'password'}
    ]
  end

  # Should return an array of DeliveryUpdate objects
  def get_delivery_updates(shipment)
    raise ::NotImplementedError, "#get_delivery_updates is not implemented for #{self.class.name}"
    example = [{
      date: "", # DD-MM-YYYY HH:MM
      description: "",
      status_code: "", # Carrier status code
      bearpost_status: "" # Should be one of Shipment.statuses
    }]
  end

  # Returns a tracking number for the shipment, as a string.
  def get_tracking_number(shipment)
    raise ::NotImplementedError, "#get_tracking_number is not implemented for #{self.class.name}"
  end

  # Authenticates the carrier with it's given credentials.
  # If no exception is raised and a string is returned,
  # it will be displayed for the user after validating the credentials.
  def authenticate!
    raise ::NotImplementedError, "#authenticate! is not implemented for #{self.class.name}"
  end

  # Should return an array of hashes, with the shipment transmitted,
  # a boolean stating if the transmittion was successful, and a return message.
  def transmit_shipments(shipments)
    raise ::NotImplementedError, "#transmit_shipments is not implemented for #{self.class.name}"
    example = [
      {
        shipment: shipment,
        success: false,
        message: 'Carrier Error: Package size is not valid'
      },
      {
        shipment: shipment,
        success: true,
        message: 'Shipment transmitted'
      }
    ]
  end

  ## OPTIONAL METHODS ##
  # Overwrite as you see fit.

  # All the hooks that should run before getting a label.
  def before_get_label(shipment)
  end

  # Any extra links to be shown on shipment show page options dropdown.
  def shipment_menu_links
    []
  end

  # Sets which view should be used in carrier settings. Will use views/carriers/_general_settings as default or
  # overwrite if you want to use a personalized view instead.
  def self.custom_settings_view
    'general_settings'
  end

  # Sets which view should be used in carrier settings. Will use views/carriers/_general_settings as default or
  # overwrite if you want to use a personalized view instead.
  def self.custom_label_view
    'general_label'
  end
end
