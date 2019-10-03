class SettingsController < ApplicationController

  def index
    @accounts = Account.all
    @api_key = Setting.find_by(key: "api_key").try(:value)
    @external_order_url = Setting.find_by(key:"external_order_url").try(:value)
  end

  def generate_api_key # REFACTOR > Move to API model
    api_key = SecureRandom.hex
  end

  def update_api_key
    api_key = generate_api_key
    Setting.find_or_create_by(key:"api_key").update(value: api_key)
    flash[:success] = "Nova chave de API criada com sucesso"
    redirect_to :settings
  end

  def update_external_order_url
    Setting.find_or_create_by(key:"external_order_url").update(value: params[:settings][:external_order_url])
    flash[:success] = "Link externo para o pedido atualizado com sucesso"
    redirect_to :settings
  end

end
