Resolvers::FindPerformer = GraphQL::Field.define do
  description 'Find a performer by ID'

  type Types::PerformerType

  argument :id, !types.ID, 'ID for Performer'

  resolve -> (obj, args, ctx) {
    return Performer.find(args[:id])
  }
end
