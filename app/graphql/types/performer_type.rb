PerformerType = GraphQL::ObjectType.define do
  name 'Performer'
  description 'A performer'

  # `!` marks a field as "non-null"
  field :id, !types.ID
  field :checksum, !types.String
  field :name, types.String
  field :scenes, types[!SceneType]
end
