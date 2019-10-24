module CarriersHelper
  def fields_for_settings(carrier, saved_settings, form)
    html = ""
    carrier.settings.each do |setting|
      html += "<div class='col-md-4'><div class='form-group'>"
      html += form.label t(setting[:field])
      if setting[:type] == 'text'
        html += form.text_field setting[:field], value: saved_settings.dig(setting[:field]), class:'form-control'
      elsif setting[:type] == 'password'
        html += form.password_field setting[:field], value: saved_settings.dig(setting[:field]), class:'form-control'
      elsif setting[:type] == 'dropdown'
        html += form.select setting[:field], options_for_select(setting[:options].map{|o|[t(o),o]},saved_settings.dig(setting[:field]) ),{}, { :class => 'form-control' }
      end
      html += "</div></div>"
    end
    html.html_safe
  end
end
