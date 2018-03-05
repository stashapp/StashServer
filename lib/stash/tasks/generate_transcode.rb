class Stash::Tasks::GenerateTranscode < Stash::Tasks::Base
  def initialize(scene:)
    super()
    @scene = scene
  end

  def start
    return if Stash::VALID_HTML5_CODECS.include?(@scene.video_codec)
    return if has_transcode?
    create_folders

    @manager.info("#{@scene.checksum} is of type #{@scene.video_codec}")
    video = FFMPEG::Movie.new(@scene.path)
    percent = 0.0

    video.transcode(temp_path, %w(-c:v libx264 -profile:v high -level 4.2 -preset superfast -crf 23 -vf scale=iw:-2 -c:a aac)) { |progress|
      rounded = progress.round(2)
      if rounded > percent
        @manager.info("Progress: #{rounded}")
        percent = rounded
      end
    }

    FileUtils.mv(temp_path, transcode_path)

    return @scene
  end

  private

    def create_folders
      FileUtils.mkdir_p(Stash::STASH_TRANSCODE_DIRECTORY) unless File.directory?(Stash::STASH_TRANSCODE_DIRECTORY)
      temp_folder = File.join(Stash::STASH_TRANSCODE_DIRECTORY, 'tmp')
      FileUtils.mkdir_p(temp_folder) unless File.directory?(temp_folder)
    end

    def temp_path
      File.join(Stash::STASH_TRANSCODE_DIRECTORY, 'tmp', "#{@scene.checksum}.mp4")
    end

    def transcode_path
      File.join(Stash::STASH_TRANSCODE_DIRECTORY, "#{@scene.checksum}.mp4")
    end

    def has_transcode?
      File.exist?(transcode_path)
    end
end
