Rails.application.routes.draw do
  get 'scenes/wall', to: 'scenes#wall', as: :scene_wall
  get 'scenes/:id', to: 'scenes#vtt', id: /.*_thumbs.vtt|.*_sprite.jpg/
  resources :scenes, except: [:create, :new, :destroy], defaults: { format: 'json' } do
    resources :scene_markers, only: [:index, :create, :destroy], controller: 'scene_markers', defaults: { format: 'json' }
  end
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream
  get 'scenes/:id/screenshot', to: 'scenes#screenshot', as: :screenshot
  get 'scenes/:id/screenshot/:seconds', to: 'scenes#screenshot'
  get 'scenes/:id/preview', to: 'scenes#preview', as: :scene_preview
  get 'scenes/:id/vtt/chapter', to: 'scenes#chapter_vtt', defaults: { format: :vtt }, as: :scene_chapter_vtt

  resources :galleries, except: [:create, :new, :destroy]
  get 'galleries/:id/:index', to: 'galleries#file', as: :gallery_file

  resources :performers, only: [:index, :show, :create, :update]
  get 'performers/:id/image', to: 'performers#image', as: :performer_image

  resources :studios, only: [:index, :show, :create, :update, :destroy], defaults: { format: 'json' }
  get 'studios/:id/image', to: 'studios#image', as: :studio_image

  resources :tags, only: [:index, :show, :create]

  get 'status', to: 'stash#status', defaults: { format: :json }, as: :status
  get 'scan', to: 'stash#scan', defaults: { format: :json }, as: :scan

  get 'search', to: 'stash#search', defaults: { format: :json }, as: :search

  root to: 'scenes#index'
  # root to: 'stash#dashboard'
end
