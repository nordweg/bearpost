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

  def shipping_methods
    hash = {}
    Account.all.each do |account|
      hash[account.name] = {}
      all.each do |carrier|
        hash[account.name][carrier.name] = carrier::SERVICES
      end
    end
    hash
  end

end

Carriers.register 'Carrier::Correios'
Carriers.register 'Carrier::Azul'
