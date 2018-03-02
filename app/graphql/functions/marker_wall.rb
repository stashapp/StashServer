class Functions::MarkerWall < GraphQL::Function
  description 'Retrieve random scene markers for the wall'

  type !types[Types::SceneMarkerType]

  argument :q, types.String

  def call(obj, args, ctx)
    SceneMarker.search_for(args[:q]).limit(80).reorder('RANDOM()')
  end
end
