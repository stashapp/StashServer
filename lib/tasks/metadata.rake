namespace :metadata do

  desc "Import JSON metadata"
  task import: ['db:drop', 'db:create', 'db:migrate'] do
    StashMetadata.import
  end

  desc "TODO"
  task export: :environment do
  end

  desc "Create VTT"
  task create_vtt: :environment do
    StashMetadata.create_vtt
  end

end
