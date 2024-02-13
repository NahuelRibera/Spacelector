Rails.application.routes.draw do
  get 'members/dashboard'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root to: 'spaces#index'

  resources :spaces do
    resources :images, only: [:new, :create, :show, :destroy] do
      resources :compartments, only: [:new, :create]
    end
  end

  resources :images, only: [] do
    resources :boxes, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :boxes, only: [] do
    resource :info, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  get '/search', to: 'search#index'

  get '/profile', to: 'profiles#show', as: :profile

  get 'checkout', to: 'checkouts#show'
  get 'checkout/:plan', to: 'checkouts#checkout', as: :checkout_plan
  get 'checkout/success', to: 'checkouts#success'
  get 'billing', to: 'billings#show'
end
