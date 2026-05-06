Rails.application.routes.draw do

  namespace :admin do
    resources :books
    resources :categories
    resources :authors
    resources :orders do
      resources :order_items, only: [:create, :update, :destroy]
    end 
    root to: "books#index"
  end

  namespace :api do
      resources :books, only: [:index, :show]
      resources :orders, only: [:create]
      namespace :webhooks do
        resources :payments, only: [:create]
      end
  end
  get "up" => "rails/health#show", as: :rails_health_check

  
end
