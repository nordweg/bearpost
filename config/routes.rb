Rails.application.routes.draw do
  root 'dashboard#index'

  get  'settings',                                   to: "settings#index"
  post 'settings/update_api_key',                    to: "settings#update_api_key"
  get  'accounts/:id/:carrier_class/edit',           to: "accounts#edit_carrier"
  post 'accounts/:id/update_carrier_settings',       to: "accounts#update_carrier_settings"
  get  'track/:shipment_number',                     to: "tracking#show"
  get  'dashboard',                                  to: "dashboard#index"

  resources :settings do
    collection do
      post :update_api_key
      post :update_external_order_url
    end
  end

  devise_for :users
  resources :users
  resources :accounts
  resources :packages
  resources :companies
  resources :carriers do
    collection do
      post 'sync_ready_shipments'
    end
    member do
      post "validate_credentials_ajax"
    end
  end

  resources :shipments do
    collection do
      post 'new_from_xml'
      get  'update_all_shipments_delivery_status'
      get  'sync_all_ready_shipments_with_carriers'
    end
    member do
      get  'save_tracking_number'
      get  'get_labels'
      post 'sync_shipment_with_carrier'
      post 'set_as_shipped'
      post 'save_delivery_updates'
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :shipments do
        member do
          get  'save_tracking_number',       to: "shipments#save_tracking_number"
          get  'get_labels',                 to: "shipments#get_labels", format: :pdf
          post 'sync_shipment_with_carrier', to: "shipments#sync_shipment_with_carrier"
          post 'update_invoice_xml',         to: "shipments#update_invoice_xml"
          post 'set_as_shipped',             to: "shipments#set_as_shipped"
        end
      end
      resources :shipping_methods
    end
  end

end
