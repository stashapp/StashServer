Resolvers::SceneMarkerTags = GraphQL::Field.define do
  description 'Organize scene markers by tag for a given scene ID'

  type !types[Types::SceneMarkerTagType]

  argument :scene_id, types.ID, 'ID for Scene'

  resolve -> (obj, args, ctx) {
    tags = {}
    scene = Scene.find(args[:scene_id])
    scene.scene_markers.each { |marker|
      if tags[marker.primary_tag.id].nil?
        # Create a new object if one doesn't already exist for this primary tag.
        tags[marker.primary_tag.id] = { tag: marker.primary_tag, scene_markers: [] }
      end
      tags[marker.primary_tag.id][:scene_markers].push(marker)
    }
    return tags.values
  }
end
