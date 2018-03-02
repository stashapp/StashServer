Resolvers::FindScene = GraphQL::Field.define do
  description 'Find a scene by ID or Checksum'

  type Types::SceneType

  argument :id, types.ID, 'ID for Scene'
  argument :checksum, types.String, 'Checksum for scene'
  resolve -> (obj, args, ctx) {
    return Scene.find(args[:id]) if args[:id]
    return Scene.find_by(checksum: args[:checksum]) if args[:checksum]
    return nil
  }
end
