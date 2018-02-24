namespace :metadata do

  desc "Import JSON metadata"
  task import: ['db:drop', 'db:create', 'db:migrate'] do
    StashMetadata::Tasks::Import.start
  end

  desc "Export JSON metadata.  Use 'rails metadata:export[true]' for a dry run."
  task :export, [:dry_run] => :environment do |t, args|
    StashMetadata::Tasks::Export.start args
  end

  desc "Scan the stash directory for new files"
  task scan: :environment do
    StashMetadata::Tasks::Scan.start
  end

  desc "Generates sprites and a VTT file for scrubbing video"
  task generate_sprites: :environment do
    StashMetadata::Tasks::GenerateSprites.start
  end

  desc "Generates webm files for mouseover previews"
  task generate_previews: :environment do
    StashMetadata::Tasks::GeneratePreviews.start
  end

  desc "Generates transcodes for videos that dont support HTML5 video"
  task generate_transcodes: :environment do
    StashMetadata::Tasks::GenerateTranscodes.start
  end

  desc "Generates marker previews"
  task generate_marker_previews: :environment do
    StashMetadata::Tasks::GenerateMarkerPreviews.start
  end

  desc "Generates all"
  task generate_all: :environment do
    StashMetadata::Tasks::GenerateSprites.start
    StashMetadata::Tasks::GeneratePreviews.start
    StashMetadata::Tasks::GenerateMarkerPreviews.start
    StashMetadata::Tasks::GenerateTranscodes.start
  end

  desc "Cleanup generated files for missing scenes"
  task cleanup: :environment do
    StashMetadata::Tasks::Cleanup.start
  end
end
