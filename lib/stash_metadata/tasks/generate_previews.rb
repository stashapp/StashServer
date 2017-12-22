module StashMetadata
  module Tasks
    module GeneratePreviews

      def self.start
        FileUtils.mkdir_p(STASH_SCREENSHOTS_DIRECTORY) unless File.directory?(STASH_SCREENSHOTS_DIRECTORY)
        tmp_dir = File.join(STASH_SCREENSHOTS_DIRECTORY, 'tmp')
        FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)

        Scene.all.each { |scene|
          path = File.join(STASH_SCREENSHOTS_DIRECTORY, "#{scene.checksum}.mp4")
          if !File.exist?(path)
            movie = WebmGenerator::Movie.new(path: scene.path)
            movie.output_filename = "#{scene.checksum}.mp4"
            movie.output_directory = STASH_SCREENSHOTS_DIRECTORY
            movie.generate
          end

          output_width = 640
          webp_path = File.join(STASH_SCREENSHOTS_DIRECTORY, "#{scene.checksum}.webp")
          tmp_path = File.join(tmp_dir, "#{scene.checksum}.webp")
          if !File.exist?(webp_path)
            cmd = "ffmpeg -v quiet -i '#{path}' -c:v libwebp -lossless 1 -q:v 70 -compression_level 6 -preset default -loop 0 -threads 4 -vf scale=#{output_width}:-2,fps=12 -an '#{tmp_path}'"
            StashMetadata.logger.info("Create marker for #{webp_path}")
            system(cmd)
            FileUtils.cp(tmp_path, webp_path)
            File.delete(tmp_path)
          end
        }
      end

    end
  end
end
