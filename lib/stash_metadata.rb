require 'fileutils'

module StashMetadata
  STASH_DIRECTORY             = File.expand_path(ENV['stash_directory'])
  STASH_METADATA_DIRECTORY    = File.expand_path(ENV['stash_metadata_directory'])
  STASH_PERFORMERS_DIRECTORY  = File.join(STASH_METADATA_DIRECTORY, 'performers')
  STASH_SCENES_DIRECTORY      = File.join(STASH_METADATA_DIRECTORY, 'scenes')
  STASH_SCREENSHOTS_DIRECTORY = File.join(STASH_METADATA_DIRECTORY, 'screenshots')
  STASH_VTT_DIRECTORY         = File.join(STASH_METADATA_DIRECTORY, 'vtt')
  STASH_MAPPINGS_FILE         = File.join(STASH_METADATA_DIRECTORY, 'mappings.json')

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
      performer.url = json['url']

      performer.save
    }

    mappings['scenes'].each { |sceneJSON|
      checksum = sceneJSON['checksum']
      path = sceneJSON['path']
      unless checksum && path
        puts "Scene mapping without checksum and path! #{sceneJSON}"
        next
      end

      scene = Scene.new
      scene.checksum = checksum
      scene.path     = path

      json = StashMetadata::JSON.scene checksum
      if json
        scene.title    = json['title']
        scene.details  = json['details']
        scene.url      = json['url']

        studio_name = json['studio']
        if studio_name
          studio = Studio.find_by(name: studio_name)
          if studio
            scene.studio = studio
          else
            puts "Created new studio #{studio_name}"
            scene.studio = Studio.create(name: studio_name)
          end
        end

        performer_names = json['performers']
        if performer_names
          performer_names.each { |performer_name|
            performer = Performer.find_by(name: performer_name)
            if performer
              scene.performers.push(performer)
            else
              puts "Performer does not exist! #{performer_name}"
            end
          }
        end

        # TODO tags
      end

      scene.save
    }

  end

  def self.create_vtt
    FileUtils.mkdir_p(STASH_VTT_DIRECTORY) unless File.directory?(STASH_VTT_DIRECTORY)

    Scene.all.each { |scene|
      path = File.join(STASH_VTT_DIRECTORY, "#{scene.checksum}_thumbs.vtt")
      next unless !File.exist?(path)

      movie = VTTGenerator::Movie.new(scene.path)
      movie.thumb_width = 160
      movie.sprite_filename = "#{scene.checksum}_sprite.jpg"
      movie.vtt_filename = "#{scene.checksum}_thumbs.vtt"
      movie.output_directory = STASH_VTT_DIRECTORY

      movie.generate
    }
  end
end
