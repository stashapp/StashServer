class Functions::FindStudios < Functions::FindRecords
  description "A function which queries Studio objects"

  FindStudiosResultType = GraphQL::ObjectType.define do
    name 'FindStudiosResultType'
    field :count, !types.Int, hash_key: :count
    field :studios, !types[Types::StudioType], hash_key: :studios
  end

  type !FindStudiosResultType

  def call(obj, args, ctx)
    q = query(args)
    studios = Studio.search_for(q)
                    .sortable(args[:filter].to_h, default: 'name')
                    .pageable(args)

    {
      count: studios.total_count,
      studios: studios
    }
  end
end
