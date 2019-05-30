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

    # make checkboxes become true/false
    # params[:settings][:shipping_methods].each do |k,v|
    #   params[:settings][:shipping_methods][k]["selected"] = ActiveRecord::Type::Boolean.new.cast(params[:settings][:shipping_methods][k]["selected"])
    # end

    current_settings = @account.send(@carrier.settings_field)
    new_settings     = current_settings.deep_merge(settings_params.to_h)
    
    if @account.update(@carrier.settings_field => new_settings)
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

    def settings_params
      params.require(:settings).permit!
    end
end
