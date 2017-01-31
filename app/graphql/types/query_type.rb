QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The query root for this schema'

  field :scenes, SceneType, field: ScenesField
  field :scene, SceneType, field: SceneField
  field :performer, PerformerType, field: PerformerField
end
