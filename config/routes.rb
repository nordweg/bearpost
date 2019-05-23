Rails.application.routes.draw do
  root 'home#index'

  get 'settings', to: "settings#index"

  resources :accounts
  resources :packages
  resources :shipments
end
