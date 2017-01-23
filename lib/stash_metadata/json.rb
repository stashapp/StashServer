module StashMetadata
  module JSON

    def self.mappings
      return nil unless File.exist? StashMetadata::STASH_MAPPINGS_FILE

      return parse StashMetadata::STASH_MAPPINGS_FILE
    end

    def self.performer checksum
      path = File.join(StashMetadata::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json")
      return nil unless File.exist? path
      return parse path
    end

    def self.scene checksum
      path = File.join(StashMetadata::STASH_SCENES_DIRECTORY, "#{checksum}.json")
      return nil unless File.exist? path
      return parse path
    end

    private

    def self.parse json_file
      file = File.read json_file
      return ::JSON.parse file
    end

  end
end
