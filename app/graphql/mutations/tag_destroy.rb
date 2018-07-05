Mutations::TagDestroy = GraphQL::Relay::Mutation.define do
  name 'TagDestroy'

  input_field :id, !types.ID

  return_field :success, !types.Boolean

  resolve ->(obj, input, ctx) {
    tag = Tag.find(input[:id])
    tag.destroy!
    return {
      success: true
    }
  }
end
