Types::SceneMarkerType = GraphQL::ObjectType.define do
  name 'SceneMarker'
  description 'A scene marker...'

  # Fields - `!` marks a field as "non-null"
  field :id,              !types.ID
  field :scene,           !Types::SceneType
  field :title,           !types.String
  field :seconds,         !types.Float
  field :primary_tag,     !Types::TagType
  field :tags,            !types[Types::TagType]

  field :stream, !types.String do
    description 'The path to stream this marker'
    resolve ->(marker, args, ctx) {
      ctx[:routes].scene_markers_stream_url(scene_id: marker.scene.id, id: marker.id, host: ctx[:base_url])
    }
  end

  field :preview, !types.String do
    description 'The path to the preview image for this marker'
    resolve ->(marker, args, ctx) {
      ctx[:routes].scene_markers_preview_url(scene_id: marker.scene.id, id: marker.id, host: ctx[:base_url])
    }
  end
end
