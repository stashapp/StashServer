class Mutations::SceneMarkerDestroy < GraphQL::Function
  argument :id, !types.ID

  type !types.Boolean

  def call(_obj, args, _ctx)
    SceneMarker.find(args[:id]).destroy
  end
end
