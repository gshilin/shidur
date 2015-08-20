Rails.application.routes.draw do
  root 'books#index'
  resources :books, only: [ :index ]
  resources :questions, only: [ :index, :new ]
  resources :bookmarks, only: [ :index, :create, :destroy ]

  resources :big_windows, only: [:index]

  namespace :admin do
    resources :books do
      post 'validate', on: :collection
    end
  end
end
