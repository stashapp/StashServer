class Functions::FindScenes < Functions::FindRecords
  description "A function which queries Scene objects"

  FindScenesResultType = GraphQL::ObjectType.define do
    name 'FindScenesResultType'
    field :count, !types.Int, hash_key: :count
    field :scenes, !types[Types::SceneType], hash_key: :scenes
  end

  ResolutionEnum = GraphQL::EnumType.define do
    name 'ResolutionEnum'
    description 'Valid resolutions'

    value 'LOW', '240p', value: '240p'
    value 'STANDARD', '480p', value: '480p'
    value 'STANDARD_HD', '720p', value: '720p'
    value 'FULL_HD', '1080p', value: '1080p'
    value 'FOUR_K', '4k', value: '4k'
  end

  SceneFilterType = GraphQL::InputObjectType.define do
    name 'SceneFilterType'

    argument :rating,       types.Int,       'Filter by rating'
    argument :resolution,   ResolutionEnum,  'Filter by resolution'
    argument :has_markers,  types.String,    'Filter to only include scenes which have markers. `true` or `false`'
    argument :is_missing,   types.String,    'Filter to only include scenes missing this property'
    argument :studio_id,    types.ID,        'Filter to only include scenes with this studio'
    argument :tags,         types[types.ID], 'Filter to only include scenes with these tags'
    argument :performer_id, types.ID,        'Filter to only include scenes with this performer'
  end

  type !FindScenesResultType

  argument :scene_filter, SceneFilterType
  argument :scene_ids,    types[types.Int], 'Find only these scenes' # TODO remove this?

  def call(obj, args, ctx)
    scenes = []

    if !args[:scene_ids].nil?
      scenes = Scene.where(id: args[:scene_ids])
                    .sortable(args.to_h, default: 'path')
                    .pageable(args)
    else
      q = query(args)
      whitelist = args[:scene_filter].to_h.slice('rating', 'resolution', 'has_markers', 'is_missing', 'studio_id', 'tags', 'performer_id')
      scenes = Scene.search_for(q)
                    .filter(whitelist)
                    .sortable(args[:filter].to_h, default: 'path')
                    .pageable(args)
    end

    {
      count: scenes.total_count,
      scenes: scenes
    }
  end
end
