Rails.application.routes.draw do
  root 'shipments#index'

  get  'settings',                                   to: "settings#index"
  get  'accounts/:id/:carrier_id/edit',              to: "accounts#edit_carrier"
  post 'accounts/:id/update_carrier_settings',       to: "accounts#update_carrier_settings"

  devise_for :users
  resources :users
  resources :carriers
  resources :accounts
  resources :packages
  resources :shipments do
    member do
      get  'get_tracking_number',  to: "shipments#get_tracking_number"
      get  'get_labels',           to: "shipments#get_labels", format: :pdf
      post 'ship',                 to: "shipments#ship"
    end
    collection do
      post 'new_from_xml',         to: "shipments#new_from_xml"
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :shipments
    end
  end

end
