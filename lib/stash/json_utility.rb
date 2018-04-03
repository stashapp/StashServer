module Stash::JSONUtility
  @@manager = Stash::Manager.instance

  def self.mappings
    return nil unless File.exist? Stash::STASH_MAPPINGS_FILE
    return parse Stash::STASH_MAPPINGS_FILE
  end

  def self.save_mappings(json:)
    @@manager.info "Saving mapping file..."
    write_json path: Stash::STASH_MAPPINGS_FILE, json: json
  end

  def self.scraped
    return nil unless File.exist? Stash::STASH_SCRAPED_FILE
    return parse Stash::STASH_SCRAPED_FILE
  end

  def self.save_scraped(json:)
    @@manager.info "Saving scraped file..."
    write_json path: Stash::STASH_SCRAPED_FILE, json: json
  end

  def self.performer(checksum)
    path = File.join(Stash::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json")
    return nil unless File.exist? path
    return parse path
  end

  def self.save_performer(checksum:, json:)
    path = File.join(Stash::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json")
    @@manager.info "Saving performer to #{checksum}.json..."
    write_json path: path, json: json
  end

  def self.scene(checksum)
    path = File.join(Stash::STASH_SCENES_DIRECTORY, "#{checksum}.json")
    return nil unless File.exist? path
    return parse path
  end

  def self.save_scene(checksum:, json:)
    path = File.join(Stash::STASH_SCENES_DIRECTORY, "#{checksum}.json")
    @@manager.info "Saving scene to #{checksum}.json..."
    write_json path: path, json: json
  end

  def self.gallery(checksum)
    path = File.join(Stash::STASH_GALLERIES_DIRECTORY, "#{checksum}.json")
    return nil unless File.exist? path
    return parse path
  end

  def self.save_gallery(checksum:, json:)
    path = File.join(Stash::STASH_GALLERIES_DIRECTORY, "#{checksum}.json")
    @@manager.info "Saving gallery to #{checksum}.json..."
    write_json path: path, json: json
  end

  def self.studio(checksum)
    path = File.join(Stash::STASH_STUDIOS_DIRECTORY, "#{checksum}.json")
    return nil unless File.exist? path
    return parse path
  end

  def self.save_studio(checksum:, json:)
    path = File.join(Stash::STASH_STUDIOS_DIRECTORY, "#{checksum}.json")
    @@manager.info "Saving studio to #{checksum}.json..."
    write_json path: path, json: json
  end

  private

    def self.parse(json_file)
      file = File.read json_file
      return ::JSON.parse file
    rescue ::JSON::ParserError => e
      @@manager.warn "Failed to parse json file #{json_file}! Exception: #{e}"
    end

    def self.write_json(path:, json:)
      File.open(path, 'w') { |f|
        f.write ::JSON.pretty_generate(json)
      }
    end
end
