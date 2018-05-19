Types::SceneMarkerTagType = GraphQL::ObjectType.define do
  name 'SceneMarkerTag'

  field :tag, !Types::TagType, hash_key: :tag
  field :scene_markers, !types[Types::SceneMarkerType], hash_key: :scene_markers
end
