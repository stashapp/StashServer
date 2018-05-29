class Functions::FindSceneMarkers < Functions::FindRecords
  description "A function which queries SceneMarker objects"

  FindSceneMarkersResultType = GraphQL::ObjectType.define do
    name 'FindSceneMarkersResultType'
    field :count, !types.Int, hash_key: :count
    field :scene_markers, !types[Types::SceneMarkerType], hash_key: :scene_markers
  end

  SceneMarkerFilterType = GraphQL::InputObjectType.define do
    name 'SceneMarkerFilterType'

    argument :tag_id, types.ID, 'Filter to only include scene markers with this tag' # todo: remove?
    argument :tags, types[types.ID], 'Filter to only include scene markers with these tags'
    argument :scene_tags, types[types.ID], 'Filter to only include scene markers attached to a scene with these tags'
  end

  type !FindSceneMarkersResultType

  argument :scene_marker_filter, SceneMarkerFilterType

  def call(obj, args, ctx)
    q = query(args)
    whitelist = args[:scene_marker_filter].to_h.slice('tag_id', 'tags', 'scene_tags')

    scene_markers = SceneMarker.search_for(q)

    if !whitelist['tags'].blank? && !whitelist['scene_tags'].blank?
      marker_tags = whitelist['tags']
      scene_tags  = whitelist['scene_tags']
      scene_markers = scene_markers.marker_and_scene_tags(marker_tags, scene_tags)
    else
      scene_markers = scene_markers.filter(whitelist)
    end

    scene_markers = scene_markers.sortable(args[:filter].to_h, default: 'title')
                                 .pageable(args)

    {
      count: scene_markers.total_count,
      scene_markers: scene_markers
    }
  end
end
