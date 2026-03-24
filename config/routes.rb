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
    # Phase 6 nested resources
    resources :volunteer_badges, only: %i[create destroy]
    resources :references, only: %i[index show new create] do
      member do
        patch :issue
        patch :decline
        get   :export_pdf
      end
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

  # Phase 3: Scheduling & Shift Management
  resources :programs do
    resources :shifts do
      member do
        post :clone
        get :checkin
        get :export_pdf
        get :ical
      end
      resources :shift_assignments, only: [:create, :destroy] do
        collection do
          post :bulk_assign
        end
        resource :attendance, only: [] do
          patch :toggle
        end
      end
    end
  end

  resources :swap_requests, only: [:index, :show, :create] do
    member do
      patch :approve
      patch :decline
    end
  end

  # QR code check-in endpoint (public — auth handled in controller)
  get "checkin/:qr_token", to: "attendances#qr_checkin", as: :qr_checkin

  # iCal feeds
  get "volunteers/:id/schedule.ics", to: "volunteer_profiles#ical", as: :volunteer_ical

  # Phase 4: Hour Tracking & Verification
  resources :hour_logs, only: %i[index show new create edit update destroy] do
    member do
      patch :approve
      patch :reject
      patch :dispute
    end
    collection do
      get  :bulk_import
      post :bulk_import
    end
  end

  resources :milestones

  get "dashboard", to: "dashboard#index", as: :dashboard

  # Phase 5: Communications
  resources :conversations, only: %i[index show new create] do
    resources :messages, only: %i[create]
  end

  resources :notifications, only: %i[index] do
    member do
      patch :mark_read
    end
    collection do
      patch :mark_all_read
    end
  end

  resources :email_templates do
    member do
      get :preview
    end
  end

  resources :email_campaigns do
    member do
      post :send_campaign
    end
    collection do
      get :preview_segment
    end
  end

  resources :announcements do
    member do
      patch :publish
      post  :schedule_send
    end
  end

  resources :broadcast_messages do
    member do
      patch :send_broadcast
    end
    collection do
      get :preview_segment
    end
  end

  # Phase 6: Recognition & Engagement
  resources :badges
  resources :leaderboard, only: [:index]

  resources :testimonials do
    member do
      patch :publish
      patch :unpublish
    end
  end

  resources :surveys do
    member do
      get :dashboard
    end
    resources :survey_responses, only: %i[new create]
  end
end
