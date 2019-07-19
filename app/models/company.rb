class Company < ApplicationRecord
  has_many :users
  has_many :shipments
  has_many :accounts

  before_create do |company|
    company.token = company.generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex
      break token unless Company.exists?(token: token)
    end
  end
end
