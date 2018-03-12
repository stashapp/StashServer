#!/usr/bin/env ruby
require 'yaml'

exit(1) if ENV["STASH_DATA"].nil?
exit(2) if ENV["STASH_METADATA"].nil?
exit(3) if ENV["STASH_CACHE"].nil?
exit(4) if ENV["STASH_DOWNLOADS"].nil?

def write_yaml
  yaml_path = File.join(ENV["APP_HOME"], 'config', 'application.yml')

  yaml = {
    'stash_directory' => ENV["STASH_DATA"],
    'stash_metadata_directory' => ENV["STASH_METADATA"],
    'stash_cache_directory' => ENV["STASH_CACHE"],
    'stash_downloads_directory' => ENV["STASH_DOWNLOADS"]
  }

  File.write(yaml_path, yaml.to_yaml)
end

def import_metadata
  database_yaml_path = File.join(ENV["APP_HOME"], 'config', 'database.yml')
  database_path = File.join(ENV["STASH_METADATA"], 'stash.sqlite3')
  database_yaml = YAML.load_file(database_yaml_path)
  database_yaml["development"]["database"] = database_path
  File.write(database_yaml_path, database_yaml.to_yaml)

  if !File.exist?(database_path)
    system "bin/rails metadata:import"
  end
end

Dir.chdir(ENV["APP_HOME"]) do
  write_yaml
  import_metadata
end
