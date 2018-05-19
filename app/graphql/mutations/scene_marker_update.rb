include InputHelper

Mutations::SceneMarkerUpdate = GraphQL::Relay::Mutation.define do
  name 'SceneMarkerUpdate'

  input_field :id,              !types.ID
  input_field :title,           !types.String
  input_field :seconds,         !types.Float
  input_field :scene_id,        !types.ID
  input_field :primary_tag_id,  !types.ID
  input_field :tag_ids,         types[types.ID]

  return_field :scene_marker, Types::SceneMarkerType

  resolve ->(obj, input, ctx) {
    scene_marker = SceneMarker.find(input[:id])
    scene_marker.attributes = validate_input(input: input, type: SceneMarker)

    scene_marker.tag_ids = input[:tag_ids] unless input[:tag_ids].nil?

    scene_marker.save!

    return { scene_marker: scene_marker }
  }
end
