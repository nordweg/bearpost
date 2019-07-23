class CompaniesController < ApplicationController
  before_action :set_company, only: [:edit, :update]

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to user_path(current_user), notice: 'Empresa atualizada com sucesso'
    end
  end

  private
  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name)
  end
end
