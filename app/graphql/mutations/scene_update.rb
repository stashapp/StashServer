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
  input_field :performer_ids, !types[types.ID]
  input_field :tag_ids,       !types[types.ID]

  return_field :scene, Types::SceneType

  resolve ->(obj, input, ctx) {
    scene               = Scene.find(input[:id])
    scene.title         = input[:title]
    scene.details       = input[:details]
    scene.url           = input[:url]
    scene.date          = input[:date]
    scene.rating        = input[:rating]
    scene.studio_id     = input[:studio_id]
    scene.performer_ids = input[:performer_ids]
    scene.tag_ids       = input[:tag_ids]

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
