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
