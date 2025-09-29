namespace :api do
  namespace :v1 do
    post 'auth/login', to: 'auth#login'

    concern :restorable do
      member { post :restore }
    end

    resources :vehicles, concerns: :restorable do
      resources :maintenance_services, only: %i[index create]
    end

    resources :maintenance_services, only: %i[update show destroy], concerns: :restorable

    get 'reports/maintenance_summary', to: 'reports#maintenance_summary'
  end
end
