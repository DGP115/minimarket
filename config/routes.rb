Rails.application.routes.draw do
  resources :reviews
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "product_categories#index"
  #
  devise_for :users
  #
  # Pages
  get "about", to: "pages#about"
  # Products
  resources :products do
    # This adds buy_product path
    post "buy", on: :member
    # This adds product_remove_image path
    delete "remove_image/:id", to: "products#remove_image", as: :remove_image
  end
  # Route for webhook from Stripe
  post "/webhook", to: "products#webhook"
  #
  ## Product Categories
  resources :product_categories do
    member do
      get :root
      get :tree_left
    end
  end
end
