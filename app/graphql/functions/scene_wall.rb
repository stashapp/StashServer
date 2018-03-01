class Functions::SceneWall < GraphQL::Function
  description 'Retrieve random scenes for the wall'

  type !types[Types::SceneType]

  argument :q, types.String

  def call(obj, args, ctx)
    Scene.search_for(args[:q]).limit(80).reorder('RANDOM()')
  end
end
