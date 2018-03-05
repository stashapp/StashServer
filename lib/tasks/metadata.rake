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
    Stash::Manager.instance.scan(job_id: 'rake')
  end

  desc "Generates sprites and a VTT file for scrubbing video"
  task generate_sprites: :environment do
    Stash::Manager.instance.generate(
      job_id: 'rake',
      sprites: true,
      previews: false,
      markers: false,
      transcodes: false
    )
  end

  desc "Generates webm files for mouseover previews"
  task generate_previews: :environment do
    Stash::Manager.instance.generate(
      job_id: 'rake',
      sprites: false,
      previews: true,
      markers: false,
      transcodes: false
    )
  end

  desc "Generates transcodes for videos that dont support HTML5 video"
  task generate_transcodes: :environment do
    Stash::Manager.instance.generate(
      job_id: 'rake',
      sprites: false,
      previews: false,
      markers: false,
      transcodes: true
    )
  end

  desc "Generates marker previews"
  task generate_marker_previews: :environment do
    Stash::Manager.instance.generate(
      job_id: 'rake',
      sprites: false,
      previews: false,
      markers: true,
      transcodes: false
    )
  end

  desc "Generates all"
  task generate_all: :environment do
    Stash::Manager.instance.generate(job_id: 'rake')
  end

  desc "Cleanup generated files for missing scenes"
  task cleanup: :environment do
    Stash::Manager.instance.clean(job_id: 'rake')
  end
end
