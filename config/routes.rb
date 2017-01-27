Rails.application.routes.draw do
  resources :scenes, only: [:index, :show]
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream

  root to: 'scenes#index'
end
