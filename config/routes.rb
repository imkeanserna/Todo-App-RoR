Rails.application.routes.draw do
  devise_for :users
  root "todos#index"

  resources :todos do
    member do
      patch :toggle
    end

    collection do
      post :bulk_action
    end
  end
end
