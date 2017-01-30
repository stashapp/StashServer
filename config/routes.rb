Rails.application.routes.draw do
  get 'scenes/:id', to: 'scenes#vtt', id: /.*_thumbs.vtt|.*_sprite.jpg/
  resources :scenes, only: [:index, :show]
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream
  get 'scenes/:id/screenshot', to: 'scenes#screenshot', as: :screenshot
  get 'scenes/:id/screenshot/:seconds', to: 'scenes#screenshot'
  get 'scenes/:id/vtt/chapter', to: 'scenes#chapter_vtt', defaults: { format: :vtt }, as: :scene_chapter_vtt

  resources :performers, only: [:index, :show]
  get 'performers/:id/image', to: 'performers#image', as: :performer_image

  resources :studios, only: [:index, :show]

  get 'search', to: 'application#search', defaults: { format: :json }, as: :search

  root to: 'scenes#index'
end
