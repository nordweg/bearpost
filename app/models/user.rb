class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :recoverable, :rememberable, :validatable, :trackable#, :registerable 

  # unloadable # This was added to be able to save first_name to user
  # https://stackoverflow.com/questions/972233/attribute-in-rails-model-appears-to-be-nil-when-its-not

  def full_name
    "#{first_name} #{last_name}"
  end
end
