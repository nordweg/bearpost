class Setting < ApplicationRecord
  validates_uniqueness_of :key
end
