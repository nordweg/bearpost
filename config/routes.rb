Rails.application.routes.draw do
  root 'shipments#index'

  get  'settings',                                   to: "settings#index"
  get  'accounts/:id/:carrier_id/edit',              to: "accounts#edit_carrier"
  post 'accounts/:id/update_carrier_settings',       to: "accounts#update_carrier_settings"

  devise_for :users
  resources :users
  resources :accounts
  resources :packages
  resources :companies
  resources :carriers do
    member do
      post 'send_to_carrier'
    end
  end
  resources :shipments do
    collection do
      get  '/',                    to: "shipments#index"
      post 'new',                  to: "shipments#new"
      get  'send_to_carriers',     to: "shipments#send_to_carriers"
    end
    member do
      get  'get_tracking_number',  to: "shipments#get_tracking_number"
      get  'get_labels',           to: "shipments#get_labels", format: :pdf
      post 'send_to_carrier',      to: "shipments#send_to_carrier"
      post 'set_as_shipped',       to: "shipments#set_as_shipped"
      post 'get_delivery_updates',          to: "shipments#get_delivery_updates"
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
