Types::MutationType = GraphQL::ObjectType.define do
  name "Mutation"

  field :sceneUpdate, field: Mutations::SceneUpdate.field

  field :sceneMarkerCreate, field: Mutations::SceneMarkerCreate.field
  field :sceneMarkerUpdate, field: Mutations::SceneMarkerUpdate.field
  field :sceneMarkerDestroy, function: Mutations::SceneMarkerDestroy.new

  field :performerCreate, field: Mutations::PerformerCreate.field
  field :performerUpdate, field: Mutations::PerformerUpdate.field

  field :studioCreate, field: Mutations::StudioCreate.field
  field :studioUpdate, field: Mutations::StudioUpdate.field

  field :tagCreate, field: Mutations::TagCreate.field
  field :tagUpdate, field: Mutations::TagUpdate.field
end
