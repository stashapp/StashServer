Mutations::StudioUpdate = GraphQL::Relay::Mutation.define do
  name 'StudioUpdate'

  input_field :id,    !types.ID
  input_field :name,  types.String
  input_field :url,   types.String
  input_field :image, types.String, 'This should be base64 encoded'

  return_field :studio, Types::StudioType

  resolve ->(obj, input, ctx) {
    studio      = Studio.find(input[:id])
    studio.name = input[:name]
    studio.url  = input[:url]

    ImageProcessor::process_image(params: input, object: studio)

    studio.save!

    return { studio: studio }
  }
end
