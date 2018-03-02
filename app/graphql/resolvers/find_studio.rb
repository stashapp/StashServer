Resolvers::FindStudio = GraphQL::Field.define do
  description 'Find a studio by ID'

  type Types::StudioType

  argument :id, !types.ID, 'ID for Studio'

  resolve -> (obj, args, ctx) {
    return Studio.find(args[:id])
  }
end
