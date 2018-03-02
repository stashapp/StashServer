module StashMetadata
  module Tasks
    module Import

      def self.start
        mappings = StashMetadata::JSON.mappings
        return unless mappings

        mappings['performers'].each.with_index(1) { |performerJSON, index|
          checksum = performerJSON['checksum']
          name = performerJSON['name']
          json = StashMetadata::JSON.performer checksum
          next unless checksum && name && json

          StashMetadata.logger.info("Importing performer #{index} of #{mappings['performers'].count}")

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
          performer.favorite = json['favorite']

          path = File.join(STASH_PERFORMERS_DIRECTORY, "#{checksum}.jpg")
          if File.exist?(path)
            performer.image = File.read(path)
          else
            performer.image = Base64.decode64(json['image'])
          end

          performer.save
        }

        mappings['studios'].each.with_index(1) { |studioJSON, index|
          checksum = studioJSON['checksum']
          name = studioJSON['name']
          json = StashMetadata::JSON.studio checksum
          next unless checksum && name && json

          StashMetadata.logger.info("Importing studio #{index} of #{mappings['studios'].count}")

          studio = Studio.new
          studio.checksum = checksum
          studio.name = name
          studio.url = json['url']
          studio.image = Base64.decode64(json['image'])

          studio.save
        } if mappings['studios']

        mappings['galleries'].each.with_index(1) { |galleryJSON, index|
          checksum = galleryJSON['checksum']
          path = galleryJSON['path']
          next unless checksum && path

          StashMetadata.logger.info("Importing gallery #{index} of #{mappings['galleries'].count}")

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
                  StashMetadata.logger.warn("Performer does not exist! #{performer_name}")
                end
              }
            end
          end

          gallery.save
        }

        mappings['scenes'].each.with_index(1) { |sceneJSON, index|
          checksum = sceneJSON['checksum']
          path = sceneJSON['path']
          unless checksum && path
            StashMetadata.logger.warn("Scene mapping without checksum and path! #{sceneJSON}")
            next
          end

          StashMetadata.logger.info("Importing scene #{index} of #{mappings['scenes'].count}")

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
                StashMetadata.logger.warn("Studio does not exist! #{studio_name}.  Creating...")
                # If there is no checksum, then it's an older studio.  Add some junk data for the image.
                # The user can update later.
                studio = Studio.new
                studio.name = studio_name
                studio.image = studio.name
                studio.checksum = Digest::MD5.hexdigest(studio.name)
                studio.save!
                scene.studio = studio
              end
            end

            gallery_checksum = json['gallery']
            if gallery_checksum
              gallery = Gallery.find_by(checksum: gallery_checksum)
              if gallery
                scene.gallery = gallery
              else
                StashMetadata.logger.warn("Gallery does not exist! #{gallery_checksum}")
              end
            end

            performer_names = json['performers']
            if performer_names
              performer_names.each { |performer_name|
                performer = Performer.find_by(name: performer_name)
                if performer
                  scene.performers.push(performer)
                else
                  StashMetadata.logger.warn("Performer does not exist! #{performer_name}")
                end
              }
            end

            tag_names = json['tags']
            if tag_names
              scene.save! # Save so that the taggings have an id for the scene relation
              tag_names.each { |tag_name|
                scene.add_tag(tag_name)
              }
            end

            markers = json['markers']
            if markers
              scene.save! # Save so that the marker can be created
              markers.each { |marker|
                scene.scene_markers.create(marker)
              }
            end

            file_info = json['file']
            if file_info
              scene.size = file_info['size']
              scene.duration = file_info['duration']
              scene.video_codec = file_info['video_codec']
              scene.audio_codec = file_info['audio_codec']
              scene.width = file_info['width']
              scene.height = file_info['height']
            else
              # TODO Get FFMPEG metadata?
            end

          end

          scene.save!
        }
      end

    end
  end
end
