Mutations::SceneMarkerCreate = GraphQL::Relay::Mutation.define do
  name 'SceneMarkerCreate'

  input_field :title,           !types.String
  input_field :seconds,         !types.Float
  input_field :scene_id,        !types.ID
  input_field :primary_tag_id,  !types.ID
  input_field :tag_ids,         types[types.ID]

  return_field :scene_marker, Types::SceneMarkerType

  resolve ->(obj, input, ctx) {
    scene = Scene.find(input[:scene_id])
    marker = scene.scene_markers.create!(input.to_h)
    return { scene_marker: marker }
  }
end
