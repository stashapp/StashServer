include InputHelper

Mutations::SceneUpdate = GraphQL::Relay::Mutation.define do
  name 'SceneUpdate'

  input_field :id,            !types.ID
  input_field :title,         types.String
  input_field :details,       types.String
  input_field :url,           types.String
  input_field :date,          types.String
  input_field :rating,        types.Int
  input_field :studio_id,     types.ID
  input_field :gallery_id,    types.ID
  input_field :performer_ids, types[types.ID]
  input_field :tag_ids,       types[types.ID]

  return_field :scene, Types::SceneType

  resolve ->(obj, input, ctx) {
    scene = Scene.find(input[:id])

    scene.attributes = validate_input(input: input, type: Scene)

    scene.studio_id     = input[:studio_id]     unless input[:studio_id].nil?
    scene.performer_ids = input[:performer_ids] unless input[:performer_ids].nil?
    scene.tag_ids       = input[:tag_ids]       unless input[:tag_ids].nil?

    if input[:gallery_id]
      if input[:gallery_id] != "0"
        scene.gallery = Gallery.find(input[:gallery_id])
      else
        scene.gallery = nil
      end
    end

    scene.save!

    return { scene: scene }
  }
end
