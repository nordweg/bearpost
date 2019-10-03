module DashboardHelper

  def params_builder(base_params, to_change_hash)
    params = base_params.permit(base_params.keys).to_h
    to_change_hash.each do |k, v|
      params[k] =  v
    end
    params
  end

end
