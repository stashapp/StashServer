Rails.application.routes.draw do
  resources :scenes, only: [:index, :show]
  root to: 'scenes#index'
end
