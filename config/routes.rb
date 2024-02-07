Rails.application.routes.draw do
  devise_for :users
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
end
