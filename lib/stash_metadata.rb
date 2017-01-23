module StashMetadata
  STASH_DIRECTORY            = File.join(Dir.home, '.stash')
  STASH_PERFORMERS_DIRECTORY = File.join(STASH_DIRECTORY, 'performers')
  STASH_SCENES_DIRECTORY     = File.join(STASH_DIRECTORY, 'scenes')
  STASH_MAPPINGS_FILE        = File.join(STASH_DIRECTORY, 'mappings.json')

  def self.import
    mappings = StashMetadata::JSON.mappings
    return unless mappings

    mappings['performers'].each { |performerJSON|
      checksum = performerJSON['checksum']
      name = performerJSON['name']
      json = StashMetadata::JSON.performer checksum
      next unless checksum && name && json

      performer = Performer.new
      performer.checksum = checksum
      performer.name = name
      performer.url = performerJSON['url']

      performer.save
    }

    mappings['scenes'].each { |sceneJSON|
      checksum = sceneJSON['checksum']
      path = sceneJSON['path']
      json = StashMetadata::JSON.scene checksum
      next unless checksum && path && json

      scene = Scene.new
      scene.checksum = checksum
      scene.path     = path
      scene.title    = sceneJSON['title']
      scene.details  = sceneJSON['details']
      scene.url      = sceneJSON['url']

      # TODO studio

      if json['performers']
        json['performers'].each { |performer_name|
          performer = Performer.find_by(name: performer_name)
          if performer
            scene.performers.push performer
          else
            logger.warning "Performer does not exist! #{performer_name}"
          end
        }
      end

      # TODO tags

      scene.save
    }

  end
end
