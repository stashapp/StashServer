Types::SceneType = GraphQL::ObjectType.define do
  name 'Scene'
  description 'A scene...'

  # interfaces [GraphQL::Relay::Node.interface]

  SceneFileType = GraphQL::ObjectType.define do
    name 'SceneFileType'

    field :size,            types.String
    field :duration,        types.Float # decimal, precision: 7, scale: 2
    field :video_codec,     types.String
    field :audio_codec,     types.String
    field :width,           types.Int
    field :height,          types.Int
  end

  ScenePathsType = GraphQL::ObjectType.define do
    name 'ScenePathsType'
    description 'A container for various related paths'

    field :screenshot, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].screenshot_url(scene.id, host: ctx[:base_url]) }
    end

    field :preview, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].scene_preview_url(scene.id, host: ctx[:base_url]) }
    end

    field :stream, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].stream_url(scene.id, host: ctx[:base_url]) + '.mp4' } #TODO extension
    end

    field :webp, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].scene_webp_url(scene.id, host: ctx[:base_url]) }
    end

    field :vtt, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].scene_url(scene.checksum, host: ctx[:base_url]) + '_thumbs.vtt' }
    end

    field :chapters_vtt, types.String do
      resolve ->(scene, args, ctx) { ctx[:routes].scene_chapter_vtt_url(scene.id, host: ctx[:base_url]) }
    end
  end

  # Fields - `!` marks a field as "non-null"
  field :id,              !types.ID
  field :checksum,        !types.String
  field :title,           types.String
  field :details,         types.String
  field :url,             types.String
  field :date,            types.String
  field :rating,          types.Int
  field :path,            !types.String

  field :file, !SceneFileType do
    resolve ->(scene, args, ctx) { scene }
  end

  field :paths, !ScenePathsType do
    resolve ->(scene, args, ctx) { scene }
  end

  field :is_streamable, !types.Boolean do
    resolve ->(scene, args, ctx) { scene.is_streamable }
  end

  field :scene_markers, !types[Types::SceneMarkerType]
  field :gallery, Types::GalleryType
  field :studio, Types::StudioType
  field :tags, !types[Types::TagType]
  field :performers, !types[Types::PerformerType]
end
