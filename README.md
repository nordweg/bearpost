# Bearpost
[![Build Status](https://semaphoreci.com/api/v1/lucaskuhn/bearpost-2/branches/master/badge.svg)](https://semaphoreci.com/lucaskuhn/bearpost-2)

Bearpost is an open source hub made to integrate and unify the communication of e-commerce websites with different shipping carriers.

Main functionalities:

- Find shipping rates
- Registering shipments with carriers
- Track shipments
- Print shipping labels


## Supported Shipping Carriers

* [Correios](http://correios.com.br/)
* [Azul cargo](http://www.azulcargo.com.br/)

Know how to [integrate with a new carrier](#).


## Roadmap

- [x] First version of the Bearpost core
- [x] Integration of new carriers using plugins
- [x] API
- [ ] Get shipping rates from different carriers
- [ ] Create and track return shipping authorizations
- [ ] Personalized pricing and delivery rules


## API Documentation

You can check the full documentation [here](https://documenter.getpostman.com/view/5260961/SWE3beWV).  
Make sure to change YOUR-TOKEN to the api token created under settings, and YOUR-BEARPOST to the proper url.

## Sample Usage

### Starting a new request

In this example we are using Ruby and [Faraday](https://github.com/lostisland/faraday) as our HTTP client to make the requests. Feel free to use your own.

```ruby
# Start a new request using your Bearpost token

request = Faraday.new(url: "https://bearpost.herokuapp.com/") do |conn|
  conn.request :json # Specifies your request is in JSON
  conn.response :json, :content_type => /\bjson$/ # Specifies your response will be sent in JSON
  conn.token_auth("YOUR BEARPOST TOKEN HERE") # Find your token under user settings > Integrations, in Bearpost
  conn.adapter Faraday.default_adapter
end
```


### Creating a new shipment

```ruby
# Call the request initiated above with the desired path and shipment information.

shipments_path = "/api/v1/shipments"

body = {
  "shipment": {
    "invoice_xml": nil, # XML string. Not required.
    "shipment_number": "R123123", # One order in your e-commerce platform could have multiple shippings
    "cost": 179, # Amount the shipment cost you
    "carrier": "Azul",
    "invoice_series": 2,
    "invoice_number": 2331,
    "first_name": "Fulano",
    "last_name": "da Fonseca",
    "email": "email@provider.com",
    "phone": "(99) 9999-9999",
    "cpf": "99999999999",
    "street": "Rod. Pres. Getúlio Vargas",
    "number": "1722",
    "complement": "Casa Branca",
    "neighborhood": "CENTRO",
    "zip": "95166000",
    "city": "Picada Café",
    "state": "RS",
    "country": "Brasil",
    "account": "Nordweg",
    "shipping_method": "Standart",
    "packages_attributes": [
      {
        "heigth": 10,
        "width": 10,
        "depth": 10,
        "weight": 10
      },
      {
        "heigth": 20,
        "width": 20,
        "depth": 20,
        "weight": 20
      }
    ]
  }
}

request.post(shipments_path, body)

```

The response should look like:
```ruby
{
  "id": 475,
  "status": "pending",
  "shipped_at": null,
  "shipment_number": "R123123",
  "order_number": null,
  "cost": 179,
  "carrier_id": "azul",
  "created_at": "2019-09-03T14:17:26.585Z",
  "invoice_series": 2,
  "invoice_number": 2331,
  "first_name": "Nordweg",
  "last_name": "Acessórios de Couro Ltda",
  "email": "atendimento@nordweg.com",
  "phone": "(54) 3285-1620",
  "cpf": "13536856000128",
  "street": "Rod. Pres. Getúlio Vargas",
  "number": "1722",
  "complement": "Casa Branca",
  "neighborhood": "CENTRO",
  "zip": "95166000",
  "city": "Picada Café",
  "state": "RS",
  "country": "Brasil",
  "account_id": 3,
  "shipping_method": "Standart",
  "tracking_number": null,
  "settings": {},
  "sent_to_carrier": false,
  "synced_with_carrier": "false"
}
```


### How to contribute

1. Fork it ( https://github.com/nordweg/bearpost/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
