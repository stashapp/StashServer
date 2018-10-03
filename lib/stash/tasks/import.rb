class Stash::Tasks::Import < Stash::Tasks::Base
  def start
    @mappings = Stash::JSONUtility.mappings
    return unless @mappings

    import_performers
    import_studios
    import_galleries
    import_tags

    ScrapedItem.transaction {
      import_scraped_sites
    }

    Scene.transaction {
      import_scenes
    }
  end

  private

    def import_scraped_sites
      scraped = Stash::JSONUtility.scraped
      return unless scraped

      scraped.each.with_index(1) { |json, index|
        @manager.info("Reading scraped site #{index} of #{scraped.count}\r")

        scraped_item = ScrapedItem.new

        scraped_item.title            = json['title']
        scraped_item.description      = json['description']
        scraped_item.url              = json['url']
        scraped_item.date             = json['date']
        scraped_item.rating           = json['rating']
        scraped_item.tags             = json['tags']
        scraped_item.models           = json['models']
        scraped_item.episode          = json['episode']
        scraped_item.gallery_filename = json['gallery_filename']
        scraped_item.gallery_url      = json['gallery_url']
        scraped_item.video_filename   = json['video_filename']
        scraped_item.video_url        = json['video_url']

        studio = get_studio(json['studio'])
        scraped_item.studio = studio if studio

        scraped_item.save!
        scraped_item.touch(:updated_at, time: Time.parse(json['updated_at']))
      }

      @manager.info("Scraped site import complete")
    end

    def import_performers
      performers = []
      @mappings['performers'].each.with_index(1) { |performerJSON, index|
        checksum = performerJSON['checksum']
        name     = performerJSON['name']
        json     = Stash::JSONUtility.performer checksum
        next unless checksum && name && json

        @manager.info("Reading performer #{index} of #{@mappings['performers'].count}\r")

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

        performers.push(performer)
      }

      @manager.info("Importing performers...")
      Performer.import(performers)
      @manager.info("Performer import complete")
    end

    def import_studios
      return unless @mappings['studios']

      studios = []
      @mappings['studios'].each.with_index(1) { |studioJSON, index|
        checksum = studioJSON['checksum']
        name     = studioJSON['name']
        json     = Stash::JSONUtility.studio checksum
        next unless checksum && name && json

        @manager.info("Reading studio #{index} of #{@mappings['studios'].count}\r")

        studio          = Studio.new
        studio.checksum = checksum
        studio.name     = name
        studio.url      = json['url']
        studio.image    = Base64.decode64(json['image'])

        studios.push(studio)
      }

      @manager.info("Importing studios...")
      Studio.import(studios)
      @manager.info("Studio import complete")
    end

    def import_galleries
      galleries = []
      @mappings['galleries'].each.with_index(1) { |galleryJSON, index|
        checksum = galleryJSON['checksum']
        path     = galleryJSON['path']
        next unless checksum && path

        @manager.info("Reading gallery #{index} of #{@mappings['galleries'].count}\r")

        gallery          = Gallery.new
        gallery.checksum = checksum
        gallery.path     = path

        json = Stash::JSONUtility.gallery checksum
        if json
          gallery.title = json['title']

          performers = get_performers(json['performers'])
          if performers
            gallery.performers = performers
          end
        end

        galleries.push(gallery)
      }

      @manager.info("Importing galleries...")
      Gallery.import(galleries)
      @manager.info("Gallery import complete")
    end

    def import_tags
      tag_names = []
      tags = []

      @mappings['scenes'].each.with_index(1) { |sceneJSON, index|
        checksum = sceneJSON['checksum']
        path     = sceneJSON['path']
        unless checksum && path
          @manager.warn("Scene mapping without checksum and path! #{sceneJSON}")
          next
        end

        @manager.info("Importing tags for scene #{index} of #{@mappings['scenes'].count}\r")

        json = Stash::JSONUtility.scene checksum
        if json
          scene_tag_names = json['tags']
          if scene_tag_names
            tag_names += scene_tag_names
          end

          markers = json['markers']
          if markers
            markers.each { |marker|
              primary_tag_name = marker['primary_tag']
              if primary_tag_name
                tag_names.push(primary_tag_name)
              end

              scene_marker_tag_names = marker['tags']
              if scene_marker_tag_names
                tag_names += scene_marker_tag_names
              end
            }
          end
        end
      }

      tag_names.uniq!

      tag_names.each { |tag_name|
        tag = Tag.new(name: tag_name)
        tags.push(tag)
      }

      @manager.info("Importing tags...")
      Tag.import(tags)
      @manager.info("Tag import complete")
    end

    def import_scenes
      @mappings['scenes'].each.with_index(1) { |sceneJSON, index|
        checksum = sceneJSON['checksum']
        path     = sceneJSON['path']
        unless checksum && path
          @manager.warn("Scene mapping without checksum and path! #{sceneJSON}")
          next
        end

        @manager.info("Importing scene #{index} of #{@mappings['scenes'].count}\r")

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

          studio = get_studio(json['studio'])
          scene.studio = studio if studio

          gallery_checksum = json['gallery']
          if gallery_checksum
            gallery = Gallery.find_by(checksum: gallery_checksum)
            if gallery
              scene.gallery = gallery
            else
              @manager.warn("Gallery does not exist! #{gallery_checksum}")
            end
          end

          performers = get_performers(json['performers'])
          if performers
            scene.performers = performers
          end

          tags = get_tags(json['tags'])
          if tags
            scene.tags = tags
          end

          markers = json['markers']
          if markers
            markers.each { |marker|
              new_marker = SceneMarker.new
              new_marker.title = marker['title']
              new_marker.seconds = marker['seconds']

              primary_tag = Tag.find_by(name: marker['primary_tag'])
              if primary_tag
                new_marker.primary_tag = primary_tag
              else
                @manager.warn("Primary tag does not exist! #{marker['primary_tag']}")
              end

              marker_tags = get_tags(marker['tags'])
              if marker_tags
                new_marker.tags = marker_tags
              end

              scene.scene_markers << new_marker
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
            scene.framerate = file_info['framerate']
            scene.bitrate = file_info['bitrate']
          else
            # TODO Get FFMPEG metadata?
          end

        end

        scene.save!(validate: false)
      }

      @manager.info("Scene import complete")
    end

    def get_studio(studio_name)
      return nil if studio_name.blank?

      studio = Studio.find_by(name: studio_name)
      if studio
        return studio
      else
        @manager.warn("Studio does not exist! #{studio_name}.")
        return nil
      end
    end

    def get_tags(tag_names)
      return nil if tag_names.blank?

      tags = Tag.where(name: tag_names)

      missing_tags = tag_names - tags.pluck(:name)
      missing_tags.each { |tag_name|
        @manager.warn("Tag does not exist! #{tag_name}")
      }

      return tags
    end

    def get_performers(performer_names)
      return nil if performer_names.blank?

      performers = Performer.where(name: performer_names)

      missing_performers = performer_names - performers.pluck(:name)
      missing_performers.each { |performer_name|
        @manager.warn("Performer does not exist! #{performer_name}")
      }

      return performers
    end
end
