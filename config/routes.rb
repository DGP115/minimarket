Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
  #
  devise_for :users
  get "users/:id/profile", to: "users#profile_show", as: :user_profile
  get "users/:id/profile", to: "users#profile_edit", as: :edit_user_profile
  patch "users/:id/profile", to: "users#profile_update", as: :update_user_profile

  #
  # Pages
  get "about", to: "pages#about"
  # Products
  resources :products do
    # This adds product_remove_image path
    member do
      get "remove_image/:attachment_id", to: "products#remove_image", as: :remove_image
    end
  end
  # Route for webhook from Stripe
  post "/webhooks/stripe", to: "webhooks#set_stripe_webhook"
  #
  # Product Categories
  resources :product_categories do
    member do
      get :add_child
    end
  end

  resources :orders
  resources :cart_items, only: %i[ show create update destroy ]
  # Note singular here since there will only ever be one cart per user session
  resource :cart, only: %i[ show edit update destroy ] do
    # Create checkout_cart_path, which maps to carts_controller checkout method
    post :checkout, on: :member
  end

  resources :reviews

  resources :review_notifications, only: %i[ index show update destroy ]

  # Search
  get "search", to: "search#index"
  get "clear", to: "search#clear"

  # for gem mission_control-jobs
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Catch-all for routing errors that excludes rails/active_storage.  Must be last route.  Directs to errors_controller routing_error method
  match "*unmatched_route",
      to: "errors#not_found",
      via: :all,
      constraints: ->(req) { !req.path.start_with?("/rails/active_storage") }
end
