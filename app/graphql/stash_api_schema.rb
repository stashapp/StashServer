StashApiSchema = GraphQL::Schema.define do
  use GraphQL::Subscriptions::ActionCableSubscriptions

  mutation(Types::MutationType)
  query(Types::QueryType)
  subscription(Types::SubscriptionType)
end

GraphQL::Errors.configure(StashApiSchema) do
  rescue_from ActiveRecord::RecordNotFound do |exception|
    nil
  end

  rescue_from ActiveRecord::RecordInvalid do |exception|
    messages = exception.record.errors.full_messages.join("\n")
    GraphQL::ExecutionError.new(messages)
  end

  rescue_from StandardError do |exception|
    GraphQL::ExecutionError.new("#{exception.inspect} --> #{exception.backtrace.first}")
  end
end
