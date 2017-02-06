Rails.application.routes.draw do
  get 'scenes/:id', to: 'scenes#vtt', id: /.*_thumbs.vtt|.*_sprite.jpg/
  resources :scenes, except: [:create, :new, :destroy]
  get 'scenes/:id/stream', to: 'scenes#stream', as: :stream
  get 'scenes/:id/screenshot', to: 'scenes#screenshot', as: :screenshot
  get 'scenes/:id/screenshot/:seconds', to: 'scenes#screenshot'
  get 'scenes/:id/vtt/chapter', to: 'scenes#chapter_vtt', defaults: { format: :vtt }, as: :scene_chapter_vtt

  resources :galleries, only: [:index, :show]
  get 'galleries/:id/:index', to: 'galleries#file', as: :gallery_file

  resources :performers, only: [:index, :show, :edit, :update]
  get 'performers/:id/image', to: 'performers#image', as: :performer_image

  resources :studios, only: [:index, :show]

  resources :tags, only: [:index, :new, :create]

  get 'search', to: 'stash#search', defaults: { format: :json }, as: :search

  post 'graphql', to: 'stash#graphql'

  root to: 'stash#dashboard'

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
end
