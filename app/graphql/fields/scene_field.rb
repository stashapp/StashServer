SceneField = GraphQL::Field.define do
  type(SceneType)
  description('Find a scene by ID or Checksum')
  argument(:id, types.Int, 'ID for Scene')
  argument(:checksum, types.String, 'Checksum for scene')
  resolve -> (obj, args, ctx) {
    return Scene.find(args[:id]) if args[:id]
    return Scene.find_by(checksum: args[:checksum]) if args[:checksum]
    return nil
  }
end
