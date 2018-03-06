class Stash::Tasks::Import < Stash::Tasks::Base
  def start
    @mappings = Stash::JSONUtility.mappings
    return unless @mappings

    import_performers
    import_studios
    import_galleries

    @mappings['scenes'].each.with_index(1) { |sceneJSON, index|
      checksum = sceneJSON['checksum']
      path     = sceneJSON['path']
      unless checksum && path
        @manager.warn("Scene mapping without checksum and path! #{sceneJSON}")
        next
      end

      @manager.info("Importing scene #{index} of #{@mappings['scenes'].count}")

      scene          = Scene.new
      scene.checksum = checksum
      scene.path     = path

      json = Stash::JSONUtility.scene checksum
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
            @manager.warn("Studio does not exist! #{studio_name}.  Creating...")
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
            @manager.warn("Gallery does not exist! #{gallery_checksum}")
          end
        end

        performer_names = json['performers']
        if performer_names
          performer_names.each { |performer_name|
            performer = Performer.find_by(name: performer_name)
            if performer
              scene.performers.push(performer)
            else
              @manager.warn("Performer does not exist! #{performer_name}")
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

  private

    def import_performers
      @mappings['performers'].each.with_index(1) { |performerJSON, index|
        checksum = performerJSON['checksum']
        name     = performerJSON['name']
        json     = Stash::JSONUtility.performer checksum
        next unless checksum && name && json

        @manager.info("Importing performer #{index} of #{@mappings['performers'].count}")

        performer               = Performer.new
        performer.checksum      = checksum
        performer.name          = name
        performer.url           = json['url']
        performer.twitter       = json['twitter']
        performer.instagram     = json['instagram']
        performer.birthdate     = json['birthdate']
        performer.ethnicity     = json['ethnicity']
        performer.country       = json['country']
        performer.eye_color     = json['eye_color']
        performer.height        = json['height']
        performer.measurements  = json['measurements']
        performer.fake_tits     = json['fake_tits']
        performer.career_length = json['career_length']
        performer.tattoos       = json['tattoos']
        performer.piercings     = json['piercings']
        performer.aliases       = json['aliases']
        performer.favorite      = json['favorite']
        performer.image         = Base64.decode64(json['image'])

        performer.save
      }
    end

    def import_studios
      return unless @mappings['studios']

      @mappings['studios'].each.with_index(1) { |studioJSON, index|
        checksum = studioJSON['checksum']
        name     = studioJSON['name']
        json     = Stash::JSONUtility.studio checksum
        next unless checksum && name && json

        @manager.info("Importing studio #{index} of #{@mappings['studios'].count}")

        studio          = Studio.new
        studio.checksum = checksum
        studio.name     = name
        studio.url      = json['url']
        studio.image    = Base64.decode64(json['image'])

        studio.save
      }
    end

    def import_galleries
      @mappings['galleries'].each.with_index(1) { |galleryJSON, index|
        checksum = galleryJSON['checksum']
        path     = galleryJSON['path']
        next unless checksum && path

        @manager.info("Importing gallery #{index} of #{@mappings['galleries'].count}")

        gallery          = Gallery.new
        gallery.checksum = checksum
        gallery.path     = path

        json = Stash::JSONUtility.gallery checksum
        if json
          gallery.title = json['title']

          performer_names = json['performers']
          if performer_names
            performer_names.each { |performer_name|
              performer = Performer.find_by(name: performer_name)
              if performer
                gallery.performers.push(performer)
              else
                @manager.warn("Performer does not exist! #{performer_name}")
              end
            }
          end
        end

        gallery.save
      }
    end
end
