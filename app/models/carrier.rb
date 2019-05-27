class Carrier < ApplicationRecord
  def self.id
    name.demodulize.downcase
  end

  def self.display_name
    id.titleize
  end

  def self.settings_field
    "#{id}_settings"
  end

  def self.tracking_url
    raise ::NotImplementedError, 'You must implement tracking_url method for this carrier.'
  end
end
