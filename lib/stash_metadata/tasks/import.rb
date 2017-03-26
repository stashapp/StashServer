module StashMetadata
  module Tasks
    module Import

      def self.start
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
          performer.twitter = json['twitter']
          performer.instagram = json['instagram']
          performer.birthdate = json['birthdate']
          performer.ethnicity = json['ethnicity']
          performer.country = json['country']
          performer.eye_color = json['eye_color']
          performer.height = json['height']
          performer.measurements = json['measurements']
          performer.fake_tits = json['fake_tits']
          performer.career_length = json['career_length']
          performer.tattoos = json['tattoos']
          performer.piercings = json['piercings']
          performer.aliases = json['aliases']

          path = File.join(STASH_PERFORMERS_DIRECTORY, "#{checksum}.jpg")
          performer.image = File.read(path)

          performer.save
        }

        mappings['galleries'].each { |galleryJSON|
          checksum = galleryJSON['checksum']
          path = galleryJSON['path']
          next unless checksum && path

          gallery = Gallery.new
          gallery.checksum = checksum
          gallery.path = path

          json = StashMetadata::JSON.gallery checksum
          if json
            gallery.title = json['title']

            performer_names = json['performers']
            if performer_names
              performer_names.each { |performer_name|
                performer = Performer.find_by(name: performer_name)
                if performer
                  gallery.performers.push(performer)
                else
                  StashMetadata.logger.warning("Performer does not exist! #{performer_name}")
                end
              }
            end
          end

          gallery.save
        }

        mappings['scenes'].each { |sceneJSON|
          checksum = sceneJSON['checksum']
          path = sceneJSON['path']
          unless checksum && path
            StashMetadata.logger.warning("Scene mapping without checksum and path! #{sceneJSON}")
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
            scene.date     = json['date']
            scene.rating   = json['rating']

            studio_name = json['studio']
            if studio_name
              studio = Studio.find_by(name: studio_name)
              if studio
                scene.studio = studio
              else
                StashMetadata.logger.info("Created new studio #{studio_name}")
                scene.studio = Studio.create(name: studio_name)
              end
            end

            gallery_checksum = json['gallery']
            if gallery_checksum
              gallery = Gallery.find_by(checksum: gallery_checksum)
              if gallery
                scene.gallery = gallery
              else
                StashMetadata.logger.warning("Gallery does not exist! #{gallery_checksum}")
              end
            end

            performer_names = json['performers']
            if performer_names
              performer_names.each { |performer_name|
                performer = Performer.find_by(name: performer_name)
                if performer
                  scene.performers.push(performer)
                else
                  StashMetadata.logger.warning("Performer does not exist! #{performer_name}")
                end
              }
            end

            tag_names = json['tags']
            if tag_names
              tag_names.each { |tag_name|
                scene.add_tag(tag_name)
              }
            end

          end

          scene.save
        }

      end

    end
  end
end
