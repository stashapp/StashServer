Mutations::TagUpdate = GraphQL::Relay::Mutation.define do
  name 'TagUpdate'

  input_field :id, !types.ID
  input_field :name, !types.String

  return_field :tag, Types::TagType

  resolve ->(obj, input, ctx) {
    tag      = Tag.find(input[:id])
    tag.name = input[:name]
    tag.save!

    return { tag: tag }
  }
end
