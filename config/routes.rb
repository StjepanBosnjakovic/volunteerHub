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

  # Phase 2: Opportunity Listings & Applications
  resources :opportunities, param: :id do
    member do
      patch :publish
      patch :close
      get :embed
      get :kanban, to: "volunteer_applications#kanban"
    end
    resources :volunteer_applications, only: [:index, :show, :new, :create, :update, :destroy] do
      collection do
        post :bulk_update
      end
    end
  end

  # Phase 2: Onboarding
  resources :onboarding_checklists do
    collection do
      get :cohort_dashboard
    end
  end

  resources :onboarding_steps, only: [] do
    resources :onboarding_progresses, only: [:create]
  end

  get "dashboard", to: "dashboard#index", as: :dashboard
end
