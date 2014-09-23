Rails.application.routes.draw do
  root 'authors#index'
  resources :authors, only: [ :index, :show ]
  resources :books, only: [ :index, :show ]

  namespace :admin do
    resources :books
  end
end
