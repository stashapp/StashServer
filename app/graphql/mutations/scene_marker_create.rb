class Mutations::SceneMarkerCreate < GraphQL::Function
  argument :title, !types.String
  argument :seconds, !types.Float
  argument :scene_id, !types.ID

  type Types::SceneMarkerType

  # the mutation method
  # _obj - is parent object, which in this case is nil
  # args - are the arguments passed
  # _ctx - is the GraphQL context (which would be discussed later)
  def call(_obj, args, _ctx)
    Scene.find(args[:scene_id]).scene_markers.create!(args.to_h)
  end
end
