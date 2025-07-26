Rails.application.routes.draw do
  # Health check (outside locale scope for Railway)
  get '/health' => proc { [200, {'Content-Type' => 'application/json'}, ['{status: "ok"}']] }
  
  # Mount Action Cable
  mount ActionCable.server => '/cable'
  
  # Locale scope for internationalization
  scope "(:locale)", locale: /#{I18n.available_locales.join("|")}/ do
    devise_for :users
    root 'home#index'

  # Posts (News/Articles)
  resources :posts do
    member do
      patch :toggle_featured
    end
    collection do
      get :category, path: 'category/:category'
    end
  end

  # Events
  resources :events do
    member do
      post :rsvp
      delete :cancel_rsvp
    end
    collection do
      get :upcoming
      get :past
      get :my_events
    end
  end

  # Forum
  resources :forum_categories, path: 'forum', only: [:index, :show] do
    resources :forum_threads, path: 'threads', except: [:index] do
      member do
        patch :lock
        patch :unlock
        patch :pin
        patch :unpin
      end
      resources :forum_replies, path: 'replies', except: [:index, :show]
    end
  end

  # Marketplace
  resources :products do
    member do
      patch :mark_sold
    end
    collection do
      get :my_products
      get :category, path: 'category/:category'
    end
  end

  # Business Directory
  resources :businesses do
    member do
      post :review
    end
    collection do
      get :my_businesses
      get :category, path: 'category/:category'
    end
    resources :business_reviews, except: [:index]
  end

  # Jobs Board
  resources :jobs do
    member do
      post :apply
    end
    collection do
      get :my_jobs
      get :my_applications
    end
  end

  # Volunteer Opportunities
  resources :volunteer_opportunities, path: 'volunteers' do
    member do
      post :apply
    end
    collection do
      get :my_opportunities
      get :my_applications
    end
  end

  # API routes
  namespace :api do
    namespace :v1 do
      resources :posts, only: [:index, :show]
      resources :events, only: [:index, :show]
      resources :forum_threads, only: [:index, :show]
      resources :products, only: [:index, :show]
      resources :businesses, only: [:index, :show]
      resources :jobs, only: [:index, :show]
      resources :volunteer_opportunities, only: [:index, :show]
    end
  end

  # Admin routes
  namespace :admin do
    resources :users
    resources :posts
    resources :events
    resources :forum_categories
    resources :database, only: [:index] do
      collection do
        post :backup
        post :restore
        get :download_backup
      end
    end
    root 'dashboard#index'
  end

  # User profile routes
  resources :users, only: [:show, :edit, :update], path: 'profile' do
    member do
      get :posts
      get :events
      get :forum_activity
    end
  end
  
  # Messaging routes
  resources :conversations, only: [:index, :show, :create, :update, :destroy] do
    resources :messages, only: [:create, :destroy]
  end

    # Search
    get '/search', to: 'search#index'
  end
  
  # Redirect root to default locale
  get '/', to: redirect("/#{I18n.default_locale}")
end