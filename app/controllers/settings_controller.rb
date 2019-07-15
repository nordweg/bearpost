class SettingsController < ApplicationController
  def index
    @accounts = current_company.accounts
  end
end
