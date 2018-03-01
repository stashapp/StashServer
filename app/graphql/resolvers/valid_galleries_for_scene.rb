Resolvers::ValidGalleriesForScene = GraphQL::Field.define do
  description 'Get the list of valid galleries for a given scene ID'

  type !types[Types::GalleryType]

  argument :scene_id, types.ID, 'ID for Scene'

  resolve -> (obj, args, ctx) {
    scene = Scene.find(args[:scene_id])
    galleries = Gallery.unowned.select { |gallery| gallery.path.include?(File.dirname(scene.path)) }
    galleries.push(scene.gallery) unless scene.gallery.nil?
    return galleries
  }
end
