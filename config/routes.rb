Rails.application.routes.draw do
  resources :expenses
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'expenses#index'

  devise_scope :user do
    # Redirests signing out users back to sign-in
    get 'users', to: 'devise/sessions#new'
  end

  devise_for :users
end
