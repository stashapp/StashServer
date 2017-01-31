ScenesField = GraphQL::Field.define do
  type types[SceneType]
  description('Find all scenes')
  argument(:filter_performers, types[types.Int], 'Scenes with performers')
  resolve -> (obj, args, ctx) {
    Scene.all.filter(args.to_h)
  }
end
