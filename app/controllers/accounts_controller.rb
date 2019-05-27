class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

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
    @account = Account.find(params[:id])
    @carrier = helpers.carrier_from_id(params[:carrier_id])
    20.times { p params[:selected_shipping_methods] }
    params[:settings][:selected_shipping_methods] = params[:selected_shipping_methods]
    20.times { p params[:settings] }
    if @account.update(@carrier.settings_field => params[:settings])
      redirect_to edit_carrier_path(@carrier.id), notice: 'Configurações atualizadas com sucesso'
    else
      redirect_to edit_carrier_path(@carrier.id), notice: 'algo deu errado'
    end
  end

  def create
    @account = Account.create(account_params)
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
      params.require(:account).permit(:name)
    end
end
