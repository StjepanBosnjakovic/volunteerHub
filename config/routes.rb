Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  root to: redirect("/users/sign_in")

  get "up" => "rails/health#show", as: :rails_health_check

  resource :organisation, only: [:show, :edit, :update]

  resources :volunteer_profiles do
    member do
      patch :archive
      get :export_pdf
    end
    collection do
      get :export_csv
      get :import
      post :import_create
    end
  end

  resources :skills, only: [:index, :create, :destroy]
  resources :interest_categories, only: [:index, :create, :destroy]
  resources :credentials, only: [:index, :show, :new, :create, :edit, :update, :destroy]

  get "dashboard", to: "dashboard#index", as: :dashboard
end
