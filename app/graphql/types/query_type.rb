Types::QueryType = GraphQL::ObjectType.define do
  name "Query"
  description "The query root for this schema"
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  field :findScene, field: Resolvers::FindScene
  field :findScenes, function: Functions::FindScenes.new

  field :findPerformer, field: Resolvers::FindPerformer
  field :findPerformers, function: Functions::FindPerformers.new

  field :findStudio, field: Resolvers::FindStudio
  field :findStudios, function: Functions::FindStudios.new

  field :findGallery, field: Resolvers::FindGallery
  field :findGalleries, function: Functions::FindGalleries.new

  field :markerWall, function: Functions::MarkerWall.new
  field :sceneWall, function: Functions::SceneWall.new

  field :markerStrings, field: Resolvers::MarkerStrings
  field :validGalleriesForScene, field: Resolvers::ValidGalleriesForScene
  field :stats, field: Resolvers::Stats

  field :metadataImport, !types.String, 'Start an import.  Returns the job ID' do
    resolve -> (obj, args, ctx) { ImportJob.new.enqueue.job_id }
  end
  field :metadataExport, !types.String, 'Start an export.  Returns the job ID' do
    resolve -> (obj, args, ctx) { ExportJob.new.enqueue.job_id }
  end
  field :metadataScan, !types.String, 'Start a scan.  Returns the job ID' do
    resolve -> (obj, args, ctx) { ScanJob.new.enqueue.job_id }
  end
  field :metadataGenerate, !types.String, 'Start generating content.  Returns the job ID' do
    resolve -> (obj, args, ctx) { GenerateJob.new.enqueue.job_id }
  end
  field :metadataClean, !types.String, 'Clean metadata.  Returns the job ID' do
    resolve -> (obj, args, ctx) { CleanJob.new.enqueue.job_id }
  end

  field :allPerformers, !types[Types::PerformerType] do
    resolve -> (obj, args, ctx) { Performer.all }
  end

  field :allStudios, !types[Types::StudioType] do
    resolve -> (obj, args, ctx) { Studio.all }
  end

  field :allTags, !types[Types::TagType] do
    resolve -> (obj, args, ctx) { Tag.all }
  end
end
