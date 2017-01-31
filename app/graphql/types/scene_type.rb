SceneType = GraphQL::ObjectType.define do
  name "Scene"
  description "A scene"
  
  # `!` marks a field as "non-null"
  field :id, !types.ID
  field :checksum, !types.String
  field :path, !types.String
  field :title, types.String
  field :performers, types[!PerformerType]
end
