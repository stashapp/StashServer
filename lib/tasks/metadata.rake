namespace :metadata do

  desc "Import JSON metadata"
  task import: ['db:drop', 'db:create', 'db:migrate'] do
    StashMetadata::Tasks::Import.start
  end

  desc "TODO"
  task export: :environment do
  end

  desc "Scan the stash directory for new files"
  task scan: :environment do
    StashMetadata::Tasks::Scan.start
  end

  desc "Generates sprites and a VTT file for scrubbing video"
  task generate_sprites: :environment do
    StashMetadata::Tasks::GenerateSprites.start
  end

end
