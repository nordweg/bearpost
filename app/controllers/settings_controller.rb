class SettingsController < ApplicationController

  def index
    @accounts = Account.all
    @api_key = Setting.find_by(key: "api_key").value
  end

  def update_settings
    settings = params
    settings.each do |setting|

    end
  end

  def generate_api_key # REFACTOR > Move to API model
    api_key = SecureRandom.hex
  end

  def update_api_key
    api_key = generate_api_key
    Setting.where(key: "api_key").delete_all
    Setting.create(key: "api_key", value: api_key)
    flash[:success] = "Nova chave de API criada com sucesso"
    redirect_to :settings
  end


end
