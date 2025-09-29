Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get '/health', to: 'health#show'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      post 'auth/login', to: 'auth#login'

      resources :vehicles do
        resources :maintenance_services, only: %i[index create]
      end

      resources :maintenance_services, only: %i[update show destroy]
      get 'reports/maintenance_summary', to: 'reports#maintenance_summary'
    end
  end

  scope module: :web do
    root 'vehicles#index'

    resources :vehicles do
      resources :maintenance_services,
                module: :vehicles, # => Web::Vehicles::MaintenanceServicesController
                only: %i[new create edit update destroy]
    end
  end
end
