module StashMetadata
  module Tasks
    module GeneratePreviews

      def self.start
        FileUtils.mkdir_p(STASH_SCREENSHOTS_DIRECTORY) unless File.directory?(STASH_SCREENSHOTS_DIRECTORY)
        tmp_dir = File.join(STASH_SCREENSHOTS_DIRECTORY, 'tmp')
        FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)

        Scene.all.each { |scene|
          path = File.join(STASH_SCREENSHOTS_DIRECTORY, "#{scene.checksum}.webm")
          next unless !File.exist?(path)

          movie = WebmGenerator::Movie.new(path: scene.path)
          movie.output_width = 480
          movie.output_filename = "#{scene.checksum}.webm"
          movie.output_directory = STASH_SCREENSHOTS_DIRECTORY

          movie.generate
        }
      end

    end
  end
end
