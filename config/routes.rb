Rails.application.routes.draw do
  get 'members/dashboard'
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  root to: 'spaces#index'

  resources :spaces do
    resources :images, only: [:new, :create, :show, :destroy, :update] do
      resources :compartments, only: [:index] # Add index to fetch compartments for an image
    end
    collection do
      get 'search'
    end
  end

  patch '/spaces/:id/update_name', to: 'spaces#update_name', as: 'update_space_name'

  resources :images, only: [] do
    resources :compartments, only: [:index] # This line sets up the route
  end

  resources :boxes, only: [] do
    resource :info, only: [:new, :create, :show, :edit, :update, :destroy]
  end

  resources :compartments do
    resources :object_infos, except: [:show] do
      collection do
        post 'create_or_update'
      end
      get 'last', on: :member, to: 'object_infos#last'
    end
  end

  get '/profile', to: 'profiles#show', as: :profile

  get 'checkout', to: 'checkouts#show'
  get 'checkout/:plan', to: 'checkouts#checkout', as: :checkout_plan
  get 'checkout/success', to: 'checkouts#success'
  get 'billing', to: 'billings#show'
  post 'compartments/:compartment_id/object_infos', to: 'object_infos#create'
  post 'convert_heic', to: 'images#convert_heic', as: :convert_heic
  get 'compartments/:compartment_id/object_infos/last', to: 'object_infos#last', as: 'fetch_last_compartment_object_info'
end
