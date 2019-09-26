class Company < ApplicationRecord
  has_many :users
  has_many :shipments
  has_many :accounts


end
