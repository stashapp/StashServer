include ImageProcessor

Mutations::PerformerCreate = GraphQL::Relay::Mutation.define do

  name 'PerformerCreate'

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
  input_field :favorite,          types.Boolean, default_value: false
  input_field :image,             !types.String, 'This should be base64 encoded'

  return_field :performer, Types::PerformerType

  resolve ->(obj, input, ctx) {
    performer               = Performer.new
    performer.name          = input[:name]
    performer.url           = input[:url]
    performer.birthdate     = input[:birthdate]
    performer.ethnicity     = input[:ethnicity]
    performer.country       = input[:country]
    performer.eye_color     = input[:eye_color]
    performer.height        = input[:height]
    performer.measurements  = input[:measurements]
    performer.fake_tits     = input[:fake_tits]
    performer.career_length = input[:career_length]
    performer.tattoos       = input[:tattoos]
    performer.piercings     = input[:piercings]
    performer.aliases       = input[:aliases]
    performer.twitter       = input[:twitter]
    performer.instagram     = input[:instagram]
    performer.favorite      = input[:favorite]

    process_image(params: input, object: performer)

    performer.save!

    return { performer: performer }
  }
end
