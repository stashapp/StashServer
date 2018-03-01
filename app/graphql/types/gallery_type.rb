Types::GalleryType = GraphQL::ObjectType.define do
  name 'Gallery'
  description 'A gallery...'

  GalleryFilesType = GraphQL::ObjectType.define do
    name 'GalleryFilesType'
    field :index, !types.Int, hash_key: :index
    field :name,  types.String, hash_key: :name
    field :path,  types.String, hash_key: :path
  end

  # Fields - `!` marks a field as "non-null"
  field :id,              !types.ID
  field :checksum,        !types.String
  field :path,            !types.String
  field :title,           types.String

  field :files, !types[GalleryFilesType] do
    description 'The files in the gallery'
    resolve ->(gallery, args, ctx) {
      gallery.files.map.with_index { |file, i|
        {index: i, name: file.name, path: ctx[:routes].gallery_file_url(gallery, index: i, host: ctx[:base_url])}
      }
    }
  end
end
