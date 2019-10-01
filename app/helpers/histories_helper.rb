module HistoriesHelper
  def tooltip_title(history)
    if history.carrier_status_code
      "ID da transportadora: #{history.carrier_status_code} = #{history.bearpost_status || 'Não mapeado'}"
    end
  end
end
