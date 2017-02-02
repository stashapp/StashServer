module StashMetadata
  module JSON

    def self.mappings
      return nil unless File.exist? StashMetadata::STASH_MAPPINGS_FILE
      return parse StashMetadata::STASH_MAPPINGS_FILE
    end

    def self.save_mappings json:
      StashMetadata.logger.info "Saving mapping file..."
      write_json path: StashMetadata::STASH_MAPPINGS_FILE, json: json
    end

    def self.performer checksum
      path = File.join(StashMetadata::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json")
      return nil unless File.exist? path
      return parse path
    end

    def self.save_performer checksum:, json:
      path = File.join(StashMetadata::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json")
      StashMetadata.logger.info "Saving performer to #{checksum}.json..."
      write_json path: path, json: json
    end

    def self.scene checksum
      path = File.join(StashMetadata::STASH_SCENES_DIRECTORY, "#{checksum}.json")
      return nil unless File.exist? path
      return parse path
    end

    def self.save_scene checksum:, json:
      path = File.join(StashMetadata::STASH_SCENES_DIRECTORY, "#{checksum}.json")
      StashMetadata.logger.info "Saving scene to #{checksum}.json..."
      write_json path: path, json: json
    end

    def self.gallery checksum
      path = File.join(StashMetadata::STASH_GALLERIES_DIRECTORY, "#{checksum}.json")
      return nil unless File.exist? path
      return parse path
    end

    def self.save_gallery checksum:, json:
      path = File.join(StashMetadata::STASH_GALLERIES_DIRECTORY, "#{checksum}.json")
      StashMetadata.logger.info "Saving gallery to #{checksum}.json..."
      write_json path: path, json: json
    end

    private

    def self.parse json_file
      file = File.read json_file
      return ::JSON.parse file
    rescue ::JSON::ParserError => e
      StashMetadata.logger.warn "Failed to parse json file #{json_file}! Exception: #{e}"
    end

    def self.write_json path:, json:
      File.open(path, 'w') { |f|
        f.write ::JSON.pretty_generate(json)
      }
    end

  end
end
