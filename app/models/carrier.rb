class Carrier
  attr_reader   :test_mode
  alias_method  :test_mode?, :test_mode
  attr_accessor :carrier_setting, :settings

  ## GENERAL DEFINITIONS ##
  # Define Carrier related constants here

  TEST_URL = ""
  LIVE_URL = ""
  TRACKING_URL = ""
  SERVICES = []

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
    [
      {field:'email',    type:'text'},
      {field:'password', type:'password'}
    ]
    raise ::NotImplementedError, "#settings is not implemented for #{self.class.name}"
  end

  # Should return an array of DeliveryUpdate objects
  def get_delivery_updates(shipment)
    raise ::NotImplementedError, "#get_delivery_updates is not implemented for #{self.class.name}"
  end

  # This method should return a tracking number for the shipment, as a string.
  def get_tracking_number(shipment)
    raise ::NotImplementedError, "#get_tracking_number is not implemented for #{self.class.name}"
  end

  # This method should authenticate the carrier with it's given credentials.
  # If a string is returned, it will be displayed for the user after validating the credentials.
  def authenticate!
    raise ::NotImplementedError, "#authenticate! is not implemented for #{self.class.name}"
  end

  # This method should respond with the an array of hashes, including the shipment,
  # a boolean stating if the sync was successful, and any message (error or success) from the result of the process.
  # It receives an array of shipments.
  def transmit_shipments(shipments)
    response_example = [
      {
        shipment: shipment
        success: false
        message: 'Carrier Error: Package size is not valid'
      },
      {
        shipment: shipment,
        success: true,
        message: 'Shipment transmitted'
      }
    ]
    raise ::NotImplementedError, 'You must implement transmit_shipments method for this carrier.'
  end

  ## OPTIONAL METHODS ##
  # Before methods, extra links and custom views. Overwrite as you see fit.

  # All the hooks that are required before a label should be set here.
  def before_get_label(shipment)
  end

  # All the hooks that are required before getting delivery updates should be set here.
  def before_get_delivery_updates(shipment)
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

  # A shipments needs to have a tracking number to get delivery updates
  extend ActiveModel::Callbacks
  define_model_callbacks :get_delivery_updates
  before_get_delivery_updates :check_tracking_number_presence
  def check_tracking_number_presence(shipment)
    raise Exception.new("#{self.class.name}: Este envio não tem rastreio") if shipment.tracking_number.blank?
  end
end
