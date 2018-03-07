Types::ScrapedPerformerType = GraphQL::ObjectType.define do
  name 'ScrapedPerformer'
  description 'A performer from a scraping operation...'

  field :name,            types.String, hash_key: :name
  field :url,             types.String, hash_key: :url
  field :twitter,         types.String, hash_key: :twitter
  field :instagram,       types.String, hash_key: :instagram
  field :birthdate,       types.String, hash_key: :birthdate
  field :ethnicity,       types.String, hash_key: :ethnicity
  field :country,         types.String, hash_key: :country
  field :eye_color,       types.String, hash_key: :eye_color
  field :height,          types.String, hash_key: :height
  field :measurements,    types.String, hash_key: :measurements
  field :fake_tits,       types.String, hash_key: :fake_tits
  field :career_length,   types.String, hash_key: :career_length
  field :tattoos,         types.String, hash_key: :tattoos
  field :piercings,       types.String, hash_key: :piercings
  field :aliases,         types.String, hash_key: :aliases
end
