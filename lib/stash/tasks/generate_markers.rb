class Stash::Tasks::GenerateMarkers < Stash::Tasks::Base
  def initialize(scene:)
    super()
    @scene = scene
  end

  def start
    return unless has_markers
    create_folders

    @manager.info("#{@scene.checksum} has #{@scene.scene_markers.count} markers")

    output_width = 640

    @scene.scene_markers.each { |marker|
      marker_path = File.join(scene_markers_path, "#{marker.seconds.to_i.to_s}.mp4")
      tmp_marker_path = File.join(temp_path, "#{marker.seconds.to_i.to_s}.mp4")

      if !File.exist?(marker_path)
        cmd = "ffmpeg -v quiet -ss #{marker.seconds.to_i} -t 20 -i \"#{@scene.path}\" -c:v libx264 -profile:v high -level 4.2 -preset veryslow -crf 24 -movflags +faststart -threads 4 -vf scale=#{output_width}:-2 -sws_flags lanczos -c:a aac -b:a 64k -strict -2 '#{tmp_marker_path}'"
        @manager.info("Creating marker video #{marker_path}")
        unless system(cmd)
          @manager.error("Error running ffmpeg #{$?}")
        end

        FileUtils.mv(tmp_marker_path, marker_path)
      end

      marker_path = File.join(scene_markers_path, "#{marker.seconds.to_i.to_s}.webp")
      tmp_marker_path = File.join(temp_path, "#{marker.seconds.to_i.to_s}.webp")
      if !File.exist?(marker_path)
        cmd = "ffmpeg -v quiet -ss #{marker.seconds.to_i} -t 5 -i '#{@scene.path}' -c:v libwebp -lossless 1 -q:v 70 -compression_level 6 -preset default -loop 0 -threads 4 -vf scale=#{output_width}:-2,fps=12 -an '#{tmp_marker_path}'"
        @manager.info("Creating marker image #{marker_path}")
        unless system(cmd)
          @manager.error("Error running ffmpeg #{$?}")
        end

        FileUtils.mv(tmp_marker_path, marker_path)
      end
    }

    return @scene
  end

  private

    def create_folders
      FileUtils.mkdir_p(Stash::STASH_MARKERS_DIRECTORY) unless File.directory?(Stash::STASH_MARKERS_DIRECTORY)
      FileUtils.mkdir_p(temp_path) unless File.directory?(temp_path)
      FileUtils.mkdir_p(scene_markers_path) unless File.directory?(scene_markers_path)
    end

    def temp_path
      File.join(Stash::STASH_MARKERS_DIRECTORY, 'tmp')
    end

    def scene_markers_path
      File.join(Stash::STASH_MARKERS_DIRECTORY, @scene.checksum)
    end

    def has_markers
      @scene.scene_markers.count > 0
    end
end
