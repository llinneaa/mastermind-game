Rails.application.routes.draw do

  root 'users#login_form'

  resources :games do
    resources :guesses, only: [:create]
    member do
      post :hint    # Handles hint requests
      post :reset   # Resets the game for a new session
    end
  end
  
  resources :users, only: [] do
    member do
      get :stats
    end
  end
  get 'dashboard', to: 'games#dashboard'
  get 'login', to: 'users#login_form'
  post 'login', to: 'users#login'
  delete 'logout', to: 'users#logout'
  get 'current_user', to: 'users#current'
  resources :users, only: [:index, :show]
end
