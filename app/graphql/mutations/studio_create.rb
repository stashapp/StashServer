include ImageProcessor

Mutations::StudioCreate = GraphQL::Relay::Mutation.define do
  name 'StudioCreate'

  input_field :name,  !types.String
  input_field :url,   types.String
  input_field :image, !types.String, 'This should be base64 encoded'

  return_field :studio, Types::StudioType

  resolve ->(obj, input, ctx) {
    studio      = Studio.new
    studio.name = input[:name]
    studio.url  = input[:url]

    process_image(params: input, object: studio)

    studio.save!

    return { studio: studio }
  }
end
