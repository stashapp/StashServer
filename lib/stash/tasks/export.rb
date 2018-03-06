class Stash::Tasks::Export < Stash::Tasks::Base
  def start
    create_folders
    @mappings = { performers: [], studios: [], galleries: [], scenes: [] }

    @manager.total = Scene.count + Gallery.count + Performer.count + Studio.count

    export_scenes
    export_galleries
    export_performers
    export_studios

    Stash::JSONUtility.save_mappings(json: @mappings)
    return nil
  end

  private

    def create_folders
      FileUtils.mkdir_p(Stash::STASH_SCENES_DIRECTORY)     unless File.directory?(Stash::STASH_SCENES_DIRECTORY)
      FileUtils.mkdir_p(Stash::STASH_GALLERIES_DIRECTORY)  unless File.directory?(Stash::STASH_GALLERIES_DIRECTORY)
      FileUtils.mkdir_p(Stash::STASH_PERFORMERS_DIRECTORY) unless File.directory?(Stash::STASH_PERFORMERS_DIRECTORY)
      FileUtils.mkdir_p(Stash::STASH_STUDIOS_DIRECTORY)    unless File.directory?(Stash::STASH_STUDIOS_DIRECTORY)
    end

    def export_scenes
      Scene.all.each do |scene|
        @manager.current += 1
        @mappings[:scenes].push(path: scene.path, checksum: scene.checksum)

        json = {}
        json[:title]      = scene.title                 if scene.title
        json[:studio]     = scene.studio.name           if scene.studio && scene.studio.name
        json[:url]        = scene.url                   if scene.url
        json[:date]       = scene.date.to_s             if scene.date
        json[:rating]     = scene.rating                if scene.rating
        json[:details]    = scene.details               if scene.details
        json[:gallery]    = scene.gallery.checksum      if scene.gallery
        json[:performers] = get_names(scene.performers) unless get_names(scene.performers).empty?
        json[:tags]       = get_names(scene.tags)       unless get_names(scene.tags).empty?

        if scene.scene_markers.count > 0
          json[:markers] = []
          scene.scene_markers.each { |marker|
            json[:markers].push(title: marker.title, seconds: marker.seconds)
          }
        elsif !json[:markers].nil?
          json.delete(:markers)
        end

        json[:file]               = {}
        json[:file][:size]        = scene.size
        json[:file][:duration]    = scene.duration
        json[:file][:video_codec] = scene.video_codec
        json[:file][:audio_codec] = scene.audio_codec
        json[:file][:width]       = scene.width
        json[:file][:height]      = scene.height

        sceneJSON = Stash::JSONUtility.scene(scene.checksum)
        next if sceneJSON == json.as_json

        Stash::JSONUtility.save_scene(checksum: scene.checksum, json: json)
      end
    end

    def export_performers
      clean_performers
      Performer.all.each do |performer|
        @manager.current += 1
        @mappings[:performers].push(name: performer.name, checksum: performer.checksum)

        json                  = {}
        json[:name]           = performer.name          if performer.name
        json[:url]            = performer.url           if performer.url
        json[:twitter]        = performer.twitter       if performer.twitter
        json[:instagram]      = performer.instagram     if performer.instagram
        json[:birthdate]      = performer.birthdate     if performer.birthdate
        json[:ethnicity]      = performer.ethnicity     if performer.ethnicity
        json[:country]        = performer.country       if performer.country
        json[:eye_color]      = performer.eye_color     if performer.eye_color
        json[:height]         = performer.height        if performer.height
        json[:measurements]   = performer.measurements  if performer.measurements
        json[:fake_tits]      = performer.fake_tits     if performer.fake_tits
        json[:career_length]  = performer.career_length if performer.career_length
        json[:tattoos]        = performer.tattoos       if performer.tattoos
        json[:piercings]      = performer.piercings     if performer.piercings
        json[:aliases]        = performer.aliases       if performer.aliases
        json[:favorite]       = performer.favorite
        json[:image]          = Base64.encode64(performer.image)

        next if json.empty?

        performerJSON = Stash::JSONUtility.performer(performer.checksum)
        next if performerJSON && performerJSON == json.as_json

        Stash::JSONUtility.save_performer(checksum: performer.checksum, json: json)
      end
    end

    def export_studios
      Studio.all.each do |studio|
        @manager.current += 1
        @mappings[:studios].push(name: studio.name, checksum: studio.checksum)

        json         = {}
        json[:name]  = studio.name if studio.name
        json[:url]   = studio.url if studio.url
        json[:image] = Base64.encode64(studio.image)

        next if json.empty?

        studioJSON = Stash::JSONUtility.studio(studio.checksum)
        next if studioJSON && studioJSON == json.as_json

        Stash::JSONUtility.save_studio(checksum: studio.checksum, json: json)
      end
    end

    def export_galleries
      Gallery.all.each do |gallery|
        @manager.current += 1
        @mappings[:galleries].push(path: gallery.path, checksum: gallery.checksum)

        json              = {}
        json[:title]      = gallery.title                 if gallery.title
        json[:performers] = get_names(gallery.performers) unless get_names(gallery.performers).empty?

        next if json.empty?

        galleryJSON = Stash::JSONUtility.gallery(gallery.checksum)
        next if galleryJSON == json.as_json

        Stash::JSONUtility.save_gallery(checksum: gallery.checksum, json: json)
      end
    end

    def get_names(objects)
      return nil unless objects

      objects.reduce([]) { |names, object|
        unless object.name.nil?
          names << object.name
        end

        names
      }
    end

    def clean_performers
      glob = File.join(Stash::STASH_PERFORMERS_DIRECTORY, "*.json")
      Dir[glob].each do |path|
        checksum = File.basename(path, '.json')
        next if Performer.find_by(checksum: checksum)

        @manager.info("Performer cleanup removing #{checksum}")
        File.delete(File.join(Stash::STASH_PERFORMERS_DIRECTORY, "#{checksum}.json"))
      end
    end
end
