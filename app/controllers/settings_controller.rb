class SettingsController < ApplicationController
  def index
    @accounts = Account.all
  end
end
