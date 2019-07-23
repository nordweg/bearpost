Rails.application.routes.draw do
  root 'shipments#index'

  get  'settings',                                   to: "settings#index"
  get  'accounts/:id/:carrier_id/edit',              to: "accounts#edit_carrier"
  post 'accounts/:id/update_carrier_settings',       to: "accounts#update_carrier_settings"

  devise_for :users
  resources :users, only: [:show,:edit,:update]
  resources :carriers
  resources :accounts
  resources :packages
  resources :companies
  resources :shipments do
    member do
      get  'get_tracking_number',  to: "shipments#get_tracking_number"
      get  'get_labels',           to: "shipments#get_labels", format: :pdf
      post 'send_to_carrier',      to: "shipments#send_to_carrier"
      post 'set_as_shipped',       to: "shipments#set_as_shipped"
    end
    collection do
      post 'new_from_xml',         to: "shipments#new_from_xml"
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :shipments do
        member do
          get  'get_tracking_number',  to: "shipments#get_tracking_number"
          get  'get_labels',           to: "shipments#get_labels", format: :pdf
          post 'send_to_carrier',      to: "shipments#send_to_carrier"
          post 'update_invoice_xml',   to: "shipments#update_invoice_xml"
          post 'set_as_shipped',       to: "shipments#set_as_shipped"
        end
      end
      resources :shipping_methods
    end
  end

end
