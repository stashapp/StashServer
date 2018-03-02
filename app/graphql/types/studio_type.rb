Types::StudioType = GraphQL::ObjectType.define do
  name 'Studio'
  description 'A studio...'

  # Fields - `!` marks a field as "non-null"
  field :id,              !types.ID
  field :checksum,        !types.String
  field :name,            !types.String
  field :url,             types.String

  field :image_path, types.String do
    resolve ->(studio, args, ctx) { ctx[:routes].studio_image_url(studio.id, host: ctx[:base_url]) }
  end

  field :scene_count, types.Int do
    resolve ->(studio, args, ctx) { studio.scenes.count }
  end
end
