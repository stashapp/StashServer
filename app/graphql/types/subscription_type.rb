Types::SubscriptionType = GraphQL::ObjectType.define do
  name "Subscription"
  field :metadataUpdate, !types.String, "Update from the meatadata manager"
end