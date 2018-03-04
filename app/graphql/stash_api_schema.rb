StashApiSchema = GraphQL::Schema.define do
  use GraphQL::Subscriptions::ActionCableSubscriptions

  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)
end

# # https://github.com/rmosolgo/graphql-ruby/blob/master/guides/queries/error_handling.md
# class Rescuable
#   def initialize(resolve_func)
#     @resolve_func = resolve_func
#   end
#
#   def call(obj, args, ctx)
#     @resolve_func.call(obj, args, ctx)
#   rescue ActiveRecord::RecordNotFound => err
#     # return no results
#     nil
#   rescue ActiveRecord::RecordInvalid => err
#     # return a GraphQL error with validation details
#     messages = err.record.errors.full_messages.join("\n")
#     GraphQL::ExecutionError.new("Validation failed: #{messages}")
#   rescue StandardError => err
#     # handle all other errors
#     GraphQL::ExecutionError.new("Unexpected error: #{err.message}")
#   end
# end
