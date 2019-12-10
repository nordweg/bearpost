module Carriers
  extend self
  attr_reader :registered
  @registered = []

  def register(class_name)
    self.registered << class_name
  end

  def all
    registered.map { |name| Object.const_get(name) }
  end

  def find(name)
    all.find { |c| c.name.downcase == name.to_s.downcase } or raise NameError, "unknown carrier #{name}"
  end

  def names_and_services
    array = []
    all.each do |carrier|
      carrier_hash = {}
      carrier_hash[:carrier] = carrier.name
      carrier_hash[:services] = carrier::SERVICES
      array << carrier_hash
    end
    array
  end

end

Carriers.register 'Carrier::Correios'
Carriers.register 'Carrier::Azul'
