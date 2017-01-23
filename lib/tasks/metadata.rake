namespace :metadata do

  desc "Import JSON metadata"
  task import: ['db:drop', 'db:create', 'db:migrate'] do
    StashMetadata.import
  end

  desc "TODO"
  task export: :environment do
  end

end
