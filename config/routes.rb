Rails.application.routes.draw do
  post '/graphql', to: 'graphql#execute'
  mount ActionCable.server => '/subscriptions'

  get 'scenes/:id', to: 'scenes#vtt', id: /.*_thumbs.vtt|.*_sprite.jpg/
  resources :scenes, except: [:create, :new, :destroy], defaults: { format: 'json' } do
    get 'scene_markers/:id/stream', to: 'scene_markers#stream', as: :markers_stream, defaults: { format: 'mp4' }
    get 'scene_markers/:id/preview', to: 'scene_markers#preview', as: :markers_preview, defaults: { format: 'webp' }
  end
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream
  get 'scenes/:id/screenshot', to: 'scenes#screenshot', as: :screenshot
  get 'scenes/:id/screenshot/:seconds', to: 'scenes#screenshot'
  get 'scenes/:id/preview', to: 'scenes#preview', as: :scene_preview
  get 'scenes/:id/webp', to: 'scenes#webp', as: :scene_webp
  get 'scenes/:id/vtt/chapter', to: 'scenes#chapter_vtt', defaults: { format: :vtt }, as: :scene_chapter_vtt

  get 'galleries/:id/:index', to: 'galleries#file', as: :gallery_file

  get 'performers/:id/image', to: 'performers#image', as: :performer_image

  get 'studios/:id/image', to: 'studios#image', as: :studio_image

  get 'status', to: 'stash#status', defaults: { format: :json }, as: :status
  get 'scan', to: 'stash#scan', defaults: { format: :json }, as: :scan

  root to: 'graphql#execute'
end
