Mutations::TagCreate = GraphQL::Relay::Mutation.define do
  name 'TagCreate'

  input_field :name, !types.String

  return_field :tag, Types::TagType

  resolve ->(obj, input, ctx) {
    tag      = Tag.new
    tag.name = input[:name]
    tag.save!

    return { tag: tag }
  }
end
