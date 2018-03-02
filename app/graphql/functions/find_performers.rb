class Functions::FindPerformers < Functions::FindRecords
  description "A function which queries Performer objects"

  FindPerformersResultType = GraphQL::ObjectType.define do
    name 'FindPerformersResultType'
    field :count, !types.Int, hash_key: :count
    field :performers, !types[Types::PerformerType], hash_key: :performers
  end

  PerformerFilterType = GraphQL::InputObjectType.define do
    name 'PerformerFilterType'

    argument :filter_favorites, types.Boolean, 'Filter by favorite'
  end

  type !FindPerformersResultType

  argument :performer_filter, PerformerFilterType

  def call(obj, args, ctx)
    q = query(args)
    whitelist = args[:performer_filter].to_h.slice('filter_favorites')
    performers = Performer.search_for(q)
                          .filter(whitelist)
                          .sortable(args[:filter].to_h, default: 'name')
                          .pageable(args)

    {
      count: performers.total_count,
      performers: performers
    }
  end
end
