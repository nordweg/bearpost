class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy, :update_carrier_settings]

  def index
    @accounts = Account.all
  end

  def show
  end

  def new
    @account = Account.new
  end

  def edit
  end

  def update_carrier_settings
    @carrier = Object.const_get params[:carrier_class]
    current_settings = @account.carrier_setting_for(@carrier).try(:settings) || {}
    new_settings = current_settings.deep_merge(settings_params.to_h)
    carrier_setting = CarrierSetting.where(account:@account,carrier_class:params[:carrier_class]).first_or_initialize
    carrier_setting.settings = new_settings
    if carrier_setting.save
      redirect_to edit_carrier_path(@carrier.to_s), notice: 'Configurações atualizadas com sucesso'
    else
      redirect_to edit_carrier_path(@carrier.to_s), notice: 'algo deu errado'
    end
  end

  def create
    @account = Account.create(account_params)
    @account.company = current_company
    if @account.save
      redirect_to settings_path, notice: 'Conta criada com sucesso'
    end
  end

  def update
    if @account.update(account_params)
      redirect_to settings_path, notice: 'Conta atualizada com sucesso'
    end
  end

  def destroy
    @account.destroy
    redirect_to settings_path, notice: 'Conta apagada'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit!
    end

    def settings_params
      params.require(:settings).permit!
    end
end
