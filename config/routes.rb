Rails.application.routes.draw do
  namespace :v1 do
    mount_devise_token_auth_for 'Account', at: 'auth', controllers: {
      sessions: 'v1/sessions',
      registrations: 'v1/registrations',
      passwords: 'v1/passwords',
      token_validations: 'v1/token_validations'
    }

    scope :auth do
      resources :password_resets, only: :create
    end

    delete 'auth', to: 'registrations#destroy'

    resources :promo_codes, only: :create
    resources :vehicles, only: %i[index create update destroy]
    resources :service_requests, only: %i[index create show destroy] do
      get :jobs, on: :collection
      post :pay, on: :member
    end
    resources :car_makes, only: :index
    resources :car_models, only: :index
    resources :model_years, only: :index
    resources :clients, only: :show
    resources :shops, only: %i[index show]
    resources :offers, only: %i[create update] do
      post :accept, on: :member

      resources :ratings, only: :create
    end
    resources :devices, only: :create
    resources :settings, only: :index

    resource :profile, only: :show
  end

  namespace :v1 do
    resources :promotions, only: [:create, :index] do
      collection do
        get :options
      end
    end
  end
  
  

  namespace :internal do
    resource :recepient, only: :show
    scope :notifications do
      post :new_message, to: 'notifications#new_message'
    end
  end
end
