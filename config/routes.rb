Rails.application.routes.draw do
  root 'home#index'

  get 'settings', to: "settings#index"
  # get 'carriers/index'
  resources :carriers

  resources :accounts
  resources :packages
  resources :shipments
end
