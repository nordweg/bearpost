#  BASE
module Carrier
  class Base
    def get_authorization_code

    end

    def cancel_shipment(shipment_number)
    end

    REVERSE_SHIPPING = []

    def self.description
      "Standart Name"
    end

  end
end


#  MODULO AZUL

module Carrier
  class Azul < Carrier::Base
    SHIPPING_CARRIERS << ["Carrier::Azul"]
    REVERSE_SHIPPING_CARRIERS << ["Carrier::Azul"]
  end
end

# Exemplo de preferences
# https://github.com/spree-contrib/spree_social/blob/master/app/models/spree/social_configuration.rb
module Spree
  class SocialConfiguration < Preferences::Configuration
    preference :path_prefix, :string, default: 'users'
  end
end

#  UTILIZAÇÃO

Shipment.azul.get_authorization_code
def compute(content_items); end
"Azul"
Array vai ser:
[carrier.description,carrier.type]
Ex:
["Azul Cargo", "Carrier::Azul"],
["Fedex Internacional", "Carrier::Fedex"],

# BASE

def quote_shipping(cep_number)
end

def create_shipping
end

def cancel_shipping(shipping_number)
end

def create_reverse_shipping
end

#

# chmod a+x (yourscriptname)

# Sender    Address Fields
t.string   :name
t.string   :last_name
t.string   :email
t.string   :phone
t.string   :cpf
t.string   :street
t.string   :number
t.string   :complement
t.string   :neighborhood
t.string   :cep
t.string   :city
t.string   :city_code
t.string   :state

# Recipient Address Fields

# Creating a controller
rails g controller Home index
rails g controller Settings index --skip-assets --skip-tests --skip-helper

# Resetting DB before tests
rake db:test:prepare
rake db:reset

# Scaffold a Controller with all crud actions for an existing table
rails g scaffold_controller Shipment

# Scaffold a Model with a field (all crud actions, tests, routes)
rails g scaffold Shipment shipment_number:string --skip-migration

#
# ac = Account.new
# ac.correios_settings[:email] = "lucas"
# ac.save


# Shipping method example
"PAC" => {
  "selected" => true,
  "range_end" => "1",
  "range_start" => "1",
  "carrier_service_id" => "1",
  "minimum_labels_stock" => "50"
  "ranges":[
    [
      "created_at",
      "prefix",
      "next_number",
      "last_number",
      "sufix",
    ],
    ["created_at", "start","end","next_number"],
    ["created_at", "start","end","next_number"],
  ]
}

#
bundle gem bearpost_correios --coc --mit -t --test=rspec
rails plugin new correios --full --database=postgresql

gem build bearpost_correios.gemspec
gem install bearpost_correios


<!--Begin::Item -->
<% @shipment.histories.each do |history| %>
  <div class="kt-timeline__item kt-timeline__item--brand">
    <div class="kt-timeline__item-section">
      <div class="kt-timeline__item-section-border">
        <div class="kt-timeline__item-section-icon">
          <i class="flaticon2-box kt-font-brand"></i>
        </div>
      </div>
      <span class="kt-timeline__item-datetime mr-3">
        <%= history.created_at.strftime("%d/%m/%Y %H:%M") %>
      </span>
    </div>
    <p class="kt-timeline__item-text">
        <%= history.description %>
    </p>
  </div>
<% end %>
<!--End::Item -->

# badge
<span class="kt-badge kt-badge--inline <%= badge_class(status) %> kt-badge--pill">
  <%= translate_status(status) %>
</span>

# badge class / translate status
def badge_class(status)
  case status
  when 'shipped'  then "kt-badge--success"
  when 'pending'  then "kt-badge--metal"
  when 'ready'    then "kt-badge--brand"
  when 'canceled' then "kt-badge--brand"
  end
end
def translate_status(status)
  case status
  when 'shipped'  then "Enviado"
  when 'pending'  then "Pendente"
  when 'ready'    then "Pronto para envio"
  when 'canceled' then "Cancelado"
  end
end

Shipment.all.each do |shipment|
  if shipment.carrier_class == 'azul'
    shipment.update(carrier_class:"Carrier::Azul")
  elsif shipment.carrier_class == 'correios'
    shipment.update(carrier_class:"Carrier::Correios")
  end
end


# <% if @carrier.shipping_methods_settings.present? %>
# <div class="row">
#   <%= f.fields_for 'shipping_methods' do |ff| %>
#   <% @carrier.shipping_methods_settings.each do |shipping_method, sm_settings| %>
#   <%= ff.fields_for shipping_method do |fff| %>
#   <div class="col-md-4">
#     <div class="kt-portlet">
#       <div class="kt-portlet__head">
#         <div class="kt-portlet__head-label">
#           <h3 class="kt-portlet__head-title">
#             <%= shipping_method %>
#           </h3>
#         </div>
#       </div>
#       <div class="kt-portlet__body" kt-hidden-height="163" style="">
#         <div class="kt-portlet__content">
#           <div class="row">
#             <% sm_settings.each do |setting| %>
#             <div class="col-md-6">
#               <div class="form-group">
#                 <%= fff.label setting %>
#                 <%= fff.text_field setting, value:settings.dig('shipping_methods',shipping_method,setting), class: "form-control" %>
#               </div>
#             </div>
#             <% end %>
#           </div>
#         </div>
#       </div>
#     </div>
#   </div>
#   <% end %>
#   <% end %>
#   <% end %>
# </div>
# <% end %>



prod_client = 9912292007

user = "igor@nordweg.com"
password = "n5wa9q"
prod_client = Savon.client(
  wsdl: "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl",
  basic_auth: [user,password],
  headers: { 'SOAPAction' => '' }
)

message = {
  "idContrato" => "9912292007",
  "idCartaoPostagem" => "0073034193",
  "usuario" => user,
  "senha" => password,
}

prod_client.call(:busca_cliente, message:message)


prod_client = Savon.client(
  wsdl: "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl",
  basic_auth: ["igor@nordweg.com","n5wa9q"],
  headers: { 'SOAPAction' => '' }
)

message = {
  "idContrato" => "9912292007",
  "idCartaoPostagem" => "0063292882",
  "usuario" => "igor@nordweg.com",
  "senha" => "n5wa9q",
}

prod_client.call(:busca_cliente, message:message)


array = []
Account.all.each do |account|
  hash = {}
  hash[:account] = account.name
  hash[:carriers] = []
  Carriers.all.each do |carrier|
    carrier_hash = {}
    carrier_hash[:name] = carrier.name
    carrier_hash[:class_name] = carrier.to_s
    carrier_hash[:shipping_methods] = carrier.shipping_methods
    hash[:carriers] << carrier_hash
  end
  array << hash
end

message = {
  "IDCotacao": 0,
  "BaseOrigem": "",
  "CEPOrigem": "13179180",
  "BaseDestino": "",
  "CEPDestino": "13080650",
  "PesoCubado": 30,
  "PesoReal": 30,
  "Volume": 1,
  "ValorTotal": 100,
  "Pedido": "",
  "Itens": [
    {
      "Volume": 1,
      "Peso": 30,
      "Altura": 15,
      "Comprimento": 40,
      "Largura": 30,
      "EspecieId": 0
    }
  ]
}

@carrier.connection.post("api/Cotacao/Enviar", message)




# PRODUCTION TESTS
client = Savon.client(
  wsdl: "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl",
  headers: { 'SOAPAction' => '' }
)

user = "igor@nordweg.com"
password = "n5wa9q"

message = {
  "idContrato" => "9912292007",
  "idCartaoPostagem" => "0063292882",
  "usuario" => user,
  "senha" => password,
}

client.call(:busca_cliente, message:message)

contrato: "9912292007"
cartao: "0063292882"
usuario: "9912292007"
senha: "n5wa9q"
ERRO: "A autenticacao de 9912292007 falhou"

contrato: "9912292007"
cartao: "0063292882"
usuario: "9912292007"
senha: "N@XQB<PVBM"
ERRO: "A autenticacao de 9912292007 falhou"

contrato: "9912292007"
cartao: "0063292882"
usuario: "igor@nordweg.com"
senha: "n5wa9q"
ERRO: "CNPJ/Cartão de Postagem utilizado não pertence ao Cliente"

message = {
"codAdministrativo"=>"12066753",
"numeroServico"=>"04162",
"cepOrigem"=>"05311900",
"cepDestino"=>"05311900",
"usuario"=>"igor@nordweg.com",
"senha"=>"n5wa9q"
}

client.call(:verifica_disponibilidade_servico, message: message)

client.call(:consulta_cep, message:{cep:"70002900"})

message = {
"numeroCartaoPostagem" => "0063292882",
"usuario"=>"igor@nordweg.com",
"senha"=>"n5wa9q"
}

client.call(:get_status_cartao_postagem, message: message)

message = {
  "tipoDestinatario" =>  "C",
  "identificador" => "13536856000128",
  "idServico" => "41068",
  "qtdEtiquetas" => "5",
  "usuario" => "igor@nordweg.com",
  "senha" => "n5wa9q",
}
client.call(:solicita_etiquetas, message: message)


### -------- DEVELOPMENT TESTS
client = Savon.client(
  wsdl: "https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl",
  headers: { 'SOAPAction' => '' }
)
message = {
"codAdministrativo"=>"17000190",
"numeroServico"=>"04162",
"cepOrigem"=>"05311900",
"cepDestino"=>"05311900",
"usuario"=>"sigep",
"senha"=>"n5f9t8"
}
client.call(:verifica_disponibilidade_servico, message:message)
