Resolvers::FindGallery = GraphQL::Field.define do
  description 'Find a gallery by ID'

  type Types::GalleryType

  argument :id, !types.ID, 'ID for Gallery'

  resolve -> (obj, args, ctx) {
    return Gallery.find(args[:id])
  }
end
