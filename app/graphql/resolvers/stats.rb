Resolvers::Stats = GraphQL::Field.define do
  description 'Get stats'

  StatsResultType = GraphQL::ObjectType.define do
    name 'StatsResultType'
    field :scene_count, !types.Int, hash_key: :scene_count
    field :gallery_count, !types.Int, hash_key: :gallery_count
    field :performer_count, !types.Int, hash_key: :performer_count
    field :studio_count, !types.Int, hash_key: :studio_count
    field :tag_count, !types.Int, hash_key: :tag_count
  end

  type !StatsResultType

  resolve -> (obj, args, ctx) {
    {
      scene_count: Scene.count,
      gallery_count: Gallery.count,
      performer_count: Performer.count,
      studio_count: Studio.count,
      tag_count: Tag.count
    }
  }
end
