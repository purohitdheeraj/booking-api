Rails.application.routes.draw do
  post '/organizers/register', to: 'organizers#register'
  post '/organizers/login',    to: 'organizers#login'
  post '/customers/register',  to: 'customers#register'
  post '/customers/login',     to: 'customers#login'

  resources :events, only: [:index, :create, :update, :destroy] do
    member do
      post 'tickets', to: 'events#create_ticket'
      get 'tickets',  to: 'events#tickets'
    end
  end

  resources :bookings, only: [:create]
end
