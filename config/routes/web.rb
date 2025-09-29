scope module: :web do
  root 'vehicles#index'

  concern :restorable do
    member { post :restore }
  end
  concern :discardable do
    collection { get :discarded }
  end

  resources :vehicles, concerns: %i[restorable discardable] do
    resources :maintenance_services,
              module: :vehicles,
              only: %i[new create edit update destroy],
              concerns: :restorable
  end
end
