class NotaFiscalParser

  def self.parse(nf_xml)
    parsed_nf = {}
    doc = Nokogiri::XML(nf_xml)
    name = doc.at_css('dest xNome').content
    first_name = name.split(" ").first
    last_name  = name.gsub(first_name, "").strip
    parsed_nf[:first_name] = first_name
    parsed_nf[:last_name] = last_name
    parsed_nf[:email] = doc.at_css('dest email').try(:content)
    parsed_nf[:phone] = doc.at_css('dest fone').try(:content)
    parsed_nf[:cpf] = doc.at_css('dest CPF').try(:content)
    parsed_nf[:street] = doc.at_css('dest xLgr').try(:content)
    parsed_nf[:number] = doc.at_css('dest nro').try(:content)
    parsed_nf[:complement] = doc.at_css('dest xCpl').try(:content)
    parsed_nf[:neighborhood] = doc.at_css('dest xBairro').try(:content)
    parsed_nf[:zip] = doc.at_css('dest CEP').try(:content)
    parsed_nf[:city] = doc.at_css('dest xMun').try(:content)
    parsed_nf[:state] = doc.at_css('dest UF').try(:content)
    parsed_nf[:country] = doc.at_css('dest xPais').try(:content)
    parsed_nf[:invoice_series] = doc.at_css('serie').try(:content)
    parsed_nf[:invoice_number] = doc.at_css('nNF').try(:content)
    parsed_nf[:cost] = doc.at_css('vNF').try(:content)
    parsed_nf[:invoice_xml] = doc.inner_html.strip
    parsed_nf
  end

end
