PerformerField = GraphQL::Field.define do
  type(PerformerType)
  description('Find a performer by ID')
  argument(:id, !types.Int, 'ID for Record')
  resolve -> (obj, args, ctx) {
    Performer.find(args[:id])
  }
end
