module StashMetadata
  module Tasks
    module GenerateTranscodes

      def self.start
        FileUtils.mkdir_p(STASH_TRANSCODE_DIRECTORY) unless File.directory?(STASH_TRANSCODE_DIRECTORY)
        tmp_dir = File.join(STASH_TRANSCODE_DIRECTORY, 'tmp')
        FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)

        Scene.all.each { |scene|
          next if VALID_HTML5_CODECS.include?(scene.video_codec)

          path = File.join(STASH_TRANSCODE_DIRECTORY, "#{scene.checksum}.mp4")
          next unless !File.exist?(path)

          StashMetadata.logger.info("#{scene.checksum} is of type #{scene.video_codec}")
          video = StashMetadata::FFMPEG.metadata(path: scene.path)
          percent = 0.0
          temp_file_path = File.join(STASH_TRANSCODE_DIRECTORY, 'tmp', "#{scene.checksum}.mp4")

          video.transcode(temp_file_path, %w(-c:v libx264 -profile:v high -level 4.2 -preset superfast -crf 23 -vf scale=iw:-2 -c:a aac)) { |progress|
            rounded = progress.round(2)
            if rounded > percent
              StashMetadata.logger.info("Progress: #{rounded}")
              percent = rounded
            end
          }

          FileUtils.cp(temp_file_path, path)
          File.delete(temp_file_path)
        }
      end

    end
  end
end
