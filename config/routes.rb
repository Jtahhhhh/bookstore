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

      resources :flash_sales do
        resources :reservations, only: [:create]
      end
  end
  get "up" => "rails/health#show", as: :rails_health_check

  
end
