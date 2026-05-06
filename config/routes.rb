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
      resources :wallets, only: [] do
        member do
          post 'deposit', to: 'wallets#deposit_funds'
          post 'withdraw', to: 'wallets#withdraw_funds'
          post 'transfer', to: 'wallets#transfer_funds'
        end
      end
  end
  get "up" => "rails/health#show", as: :rails_health_check

  
end
