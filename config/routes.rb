Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resource :session, only: %i[show create destroy]
      resource :dashboard, only: :show
      resource :options, only: :show
      resources :expenses, only: %i[index show create update destroy]
      resources :users
    end
  end

  devise_for :users, skip: [:registrations]

  root 'home#index'
  get '*path', to: 'home#index', constraints: ->(request) {
    !request.path.start_with?('/api', '/rails/', '/packs/', '/users/')
  }
end
