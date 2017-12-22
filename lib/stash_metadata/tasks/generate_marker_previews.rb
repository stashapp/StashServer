module StashMetadata
  module Tasks
    module GenerateMarkerPreviews

      def self.start
        FileUtils.mkdir_p(STASH_TRANSCODE_DIRECTORY) unless File.directory?(STASH_TRANSCODE_DIRECTORY)
        tmp_dir = File.join(STASH_TRANSCODE_DIRECTORY, 'tmp')
        FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)

        Scene.has_markers('true').each { |scene|
          StashMetadata.logger.info("#{scene.checksum} has #{scene.scene_markers.count} markers")

          scene_path = File.join(STASH_TRANSCODE_DIRECTORY, scene.checksum)
          FileUtils.mkdir_p(scene_path) unless File.directory?(scene_path)

          output_width = 640

          scene.scene_markers.each { |marker|
            marker_path = File.join(scene_path, "#{marker.seconds.to_i.to_s}.mp4")
            tmp_marker_path = File.join(tmp_dir, "#{marker.seconds.to_i.to_s}.mp4")
            if !File.exist?(marker_path)
              cmd = "ffmpeg -v quiet -ss #{marker.seconds.to_i} -t 20 -i \"#{scene.path}\" -c:v libx264 -profile:v high -level 4.2 -preset veryslow -crf 24 -movflags +faststart -threads 4 -vf scale=#{output_width}:-2 -sws_flags lanczos -c:a aac -b:a 64k '#{tmp_marker_path}'"
              StashMetadata.logger.info("Create marker for #{marker_path}")
              system(cmd)
              FileUtils.cp(tmp_marker_path, marker_path)
              File.delete(tmp_marker_path)
            end

            marker_path = File.join(scene_path, "#{marker.seconds.to_i.to_s}.webp")
            tmp_marker_path = File.join(tmp_dir, "#{marker.seconds.to_i.to_s}.webp")
            if !File.exist?(marker_path)
              cmd = "ffmpeg -v quiet -ss #{marker.seconds.to_i} -t 5 -i '#{scene.path}' -c:v libwebp -lossless 1 -q:v 70 -compression_level 6 -preset default -loop 0 -threads 4 -vf scale=#{output_width}:-2,fps=12 -an '#{tmp_marker_path}'"
              StashMetadata.logger.info("Create marker for #{marker_path}")
              system(cmd)
              FileUtils.cp(tmp_marker_path, marker_path)
              File.delete(tmp_marker_path)
            end
          }
        }
      end

    end
  end
end
