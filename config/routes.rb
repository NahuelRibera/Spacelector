Rails.application.routes.draw do
  devise_for :users
  root to: 'spaces#index'

  resources :spaces do
    resources :images, only: [:new, :create, :show, :destroy] do
      resources :boxes, only: [:new, :create]
    end
  end

  resources :boxes do
    resource :info, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  get '/search', to: 'search#index'
end
