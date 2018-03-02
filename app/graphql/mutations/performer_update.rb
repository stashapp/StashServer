include ImageProcessor
include InputHelper

Mutations::PerformerUpdate = GraphQL::Relay::Mutation.define do

  name 'PerformerUpdate'

  input_field :id,                !types.ID
  input_field :name,              types.String
  input_field :url,               types.String
  input_field :birthdate,         types.String
  input_field :ethnicity,         types.String
  input_field :country,           types.String
  input_field :eye_color,         types.String
  input_field :height,            types.String
  input_field :measurements,      types.String
  input_field :fake_tits,         types.String
  input_field :career_length,     types.String
  input_field :tattoos,           types.String
  input_field :piercings,         types.String
  input_field :aliases,           types.String
  input_field :twitter,           types.String
  input_field :instagram,         types.String
  input_field :favorite,          types.Boolean
  input_field :image,             types.String, 'This should be base64 encoded'

  return_field :performer, Types::PerformerType

  resolve ->(obj, input, ctx) {
    performer = Performer.find(input[:id])
    performer.attributes = validate_input(input: input, type: Performer)

    process_image(params: input, object: performer)

    performer.save!

    return { performer: performer }
  }
end
