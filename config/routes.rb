Rails.application.routes.draw do
  resources :scenes, only: [:index, :show]
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream
  get 'scenes/:id/screenshot', to: 'scenes#screenshot', as: :screenshot
  get 'scenes/:id/screenshot/:seconds', to: 'scenes#screenshot'

  resources :performers, only: [:index, :show]

  resources :studios, only: [:index, :show]

  root to: 'scenes#index'
end
