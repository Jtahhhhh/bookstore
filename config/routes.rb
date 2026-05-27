Rails.application.routes.draw do
  devise_for :users

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
      namespace :webhooks do
        resources :payments, only: [:create]
      end
      resources :wallets, only: [] do
        member do
          post 'deposit', to: 'wallets#deposit_funds'
          post 'withdraw', to: 'wallets#withdraw_funds'
          post 'transfer', to: 'wallets#transfer_funds'
        end
      end
      
      resources :coupons, only: [] do
        collection do
          post :preview
        end
      end
      
  end
  get "up" => "rails/health#show", as: :rails_health_check

  
end
