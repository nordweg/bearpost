# require 'capybara_helper'
require 'rails_helper'
require 'capybara/rails'

describe "the home page" do
  it "works" do
    visit "/"
  end
end
