class Functions::FindGalleries < Functions::FindRecords
  description "A function which queries Gallery objects"

  FindGalleriesResultType = GraphQL::ObjectType.define do
    name 'FindGalleriesResultType'
    field :count, !types.Int, hash_key: :count
    field :galleries, !types[Types::GalleryType], hash_key: :galleries
  end

  type !FindGalleriesResultType

  def call(obj, args, ctx)
    q = query(args)
    galleries = Gallery.search_for(q)
                       .sortable(args[:filter].to_h, default: 'title')
                       .pageable(args)

    {
      count: galleries.total_count,
      galleries: galleries
    }
  end
end
