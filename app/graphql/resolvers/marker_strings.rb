Resolvers::MarkerStrings = GraphQL::Field.define do
  description 'Get marker strings'

  MarkerStringsResultType = GraphQL::ObjectType.define do
    name 'MarkerStringsResultType'
    field :id, !types.ID, hash_key: :id
    field :title, !types.String, hash_key: :title
    field :count, !types.Int, hash_key: :count
  end

  type !types[MarkerStringsResultType]

  argument :q, types.String
  argument :sort, types.String

  resolve -> (obj, args, ctx) {
    markers = SceneMarker.search_for(args[:q])
                         .sortable({}, default: 'title')
                         .group(:title).count.map { |e| {id: e[0], title: e[0], count: e[1]} }
    markers.sort_by! { |e| e[:count] }.reverse! if args[:sort] == 'count'
    return markers
  }
end
