Resolvers::FindTag = GraphQL::Field.define do
  description 'Find a tag by ID'

  type Types::TagType

  argument :id, !types.ID, 'ID for Tag'

  resolve -> (obj, args, ctx) {
    return Tag.find(args[:id])
  }
end
