Rails.application.routes.draw do
  root 'authors#index'
  resources :authors, only: [ :index, :show ]
  resources :books, only: [ :index, :show ]

  resources :big_windows, only: [:index]

  namespace :admin do
    resources :books do
      post 'validate', on: :collection
    end
  end
end
