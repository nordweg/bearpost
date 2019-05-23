class Carrier::Correios < Carrier

  def self.id
    'correios'
  end

  def self.display_name
    id.titleize
  end

  def self.settings_field
    "#{id}_settings"
  end

  def self.settings
    ['username','password','posting_card','another_idea']
  end

  def tracking_code
    "codigo dos correios"
  end

end
