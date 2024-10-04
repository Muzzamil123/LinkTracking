Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :posts
  resources :link_clicks, only: :create
  namespace :admins do
    get 'dashboard'
  end

  root "posts#index"
end
