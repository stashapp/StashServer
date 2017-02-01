module StashMetadata
  module Tasks
    module GenerateSprites

      def self.start
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
  end
end
