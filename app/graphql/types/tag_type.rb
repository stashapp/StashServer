Types::TagType = GraphQL::ObjectType.define do
  name 'Tag'
  description 'A tag...'

  # interfaces [GraphQL::Relay::Node.interface]

  # Fields - `!` marks a field as "non-null"
  field :id,                    !types.ID
  field :name,                  !types.String

  field :scene_count, types.Int do
    resolve ->(tag, args, ctx) { tag.scenes.count }
  end

  field :scene_marker_count, types.Int do
    resolve ->(tag, args, ctx) {
      tag.primary_scene_markers.count + tag.scene_markers.count
    }
  end
end
