Rails.application.routes.draw do
  devise_for :admins
  root "pages#home"

  get "about",   to: "pages#about",   as: :about
  get "plant",   to: "pages#plant",   as: :plant
  get "clients", to: "pages#clients", as: :clients
  get "contact", to: "pages#contact", as: :contact

  resources :products, only: [ :index, :show ], param: :slug
  resources :enquiries, only: [ :create ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
