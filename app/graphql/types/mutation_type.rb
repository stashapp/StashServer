Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :sceneUpdate, field: Mutations::SceneUpdate.field

  field :sceneMarkerCreate, function: Mutations::SceneMarkerCreate.new
  field :sceneMarkerDestroy, function: Mutations::SceneMarkerDestroy.new

  field :performerCreate, field: Mutations::PerformerCreate.field
  field :performerUpdate, field: Mutations::PerformerUpdate.field

  field :studioCreate, field: Mutations::StudioCreate.field
  field :studioUpdate, field: Mutations::StudioUpdate.field

  field :tagCreate, field: Mutations::TagCreate.field
  field :tagUpdate, field: Mutations::TagUpdate.field
end
