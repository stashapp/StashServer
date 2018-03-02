Types::PerformerType = GraphQL::ObjectType.define do
  name 'Performer'
  description 'A performer...'

  # Fields - `!` marks a field as "non-null"
  field :id,              !types.ID
  field :checksum,        !types.String
  field :name,            types.String
  field :url,             types.String
  field :twitter,         types.String
  field :instagram,       types.String
  field :birthdate,       types.String
  field :ethnicity,       types.String
  field :country,         types.String
  field :eye_color,       types.String
  field :height,          types.String
  field :measurements,    types.String
  field :fake_tits,       types.String
  field :career_length,   types.String
  field :tattoos,         types.String
  field :piercings,       types.String
  field :aliases,         types.String
  field :favorite,        !types.Boolean

  field :image_path, types.String do
    resolve ->(performer, args, ctx) { ctx[:routes].performer_image_url(performer.id, host: ctx[:base_url]) }
  end

  field :scene_count, types.Int do
    resolve ->(performer, args, ctx) { performer.scenes.count }
  end

  field :scenes, !types[Types::SceneType]
end
