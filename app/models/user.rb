class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

  belongs_to :company
  has_many   :shipments, through: :company

  before_create do |user|
    user.token = user.generate_token
  end

  def generate_token
    loop do
      token = SecureRandom.hex
      break token unless User.exists?(token: token)
    end
  end
end
