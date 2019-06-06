module ApplicationHelper
  def flash_class(level)
    case level
    when 'notice'  then "primary"
    when 'success' then "success"
    when 'error'   then "danger"
    when 'alert'   then "warning"
    end
  end
end
