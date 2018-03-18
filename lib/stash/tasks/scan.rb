class Stash::Tasks::Scan < Stash::Tasks::Base
  def initialize(path:)
    super()
    @path = path
  end

  def start
    create_folders
    @manager = Stash::Manager.instance
    @klass = path_class

    item = @klass.find_by(path: @path)
    if item
      make_screenshots(path: item.path, checksum: item.checksum) if @klass == Scene
      return nil # We already have this item in the database, keep going
    end

    checksum = calculate_checksum

    begin
      make_screenshots(path: @path, checksum: checksum) if @klass == Scene
    rescue
      @manager.error("Error encoutered generating screenshots for #{@path}. Skipping.")
      return nil
    end

    item = @klass.find_by(checksum: checksum)
    if item
      @manager.info("#{@path} already exists.  Updating path...")
      item.path = @path
      item.save
    else
      @manager.info("#{@path} doesn't exist.  Creating new item...")
      item = @klass.new(path: @path, checksum: checksum)

      if @klass == Scene
        video = FFMPEG::Movie.new(@path)
        item.size        = video.size
        item.duration    = video.duration
        item.video_codec = video.video_codec
        item.audio_codec = video.audio_codec
        item.width       = video.width
        item.height      = video.height
      end

      item.save
    end

    return @path
  end

  private

    def create_folders
      FileUtils.mkdir_p(Stash::STASH_SCREENSHOTS_DIRECTORY) unless File.directory?(Stash::STASH_SCREENSHOTS_DIRECTORY)
      tmp_dir = File.join(Stash::STASH_SCREENSHOTS_DIRECTORY, 'tmp')
      FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)
    end

    def path_class
      if File.extname(@path) == '.zip'
        Gallery
      else
        Scene
      end
    end

    def calculate_checksum
      @manager.info("#{@path} not found.  Calculating checksum...")
      checksum = Digest::MD5.file(@path).hexdigest
      @manager.debug("Checksum calculated: #{checksum}")
      return checksum
    end

    def make_screenshots(path:, checksum:)
      thumb_path = File.join(Stash::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.thumb.jpg")
      normal_path = File.join(Stash::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.jpg")

      if File.exist?(thumb_path) && File.exist?(normal_path)
        # Screenshots already exist for this path... skipping
        return
      end

      movie = FFMPEG::Movie.new(path)
      make_screenshot(movie: movie, path: thumb_path, quality: 5, width: 320)
      make_screenshot(movie: movie, path: normal_path, quality: 2, width: movie.width)
    end

    def make_screenshot(movie:, path:, quality:, width:)
      time = movie.duration * 0.2
      transcoder_options = { input_options: { v: 'quiet', ss: "#{time}" } }
      options = { screenshot: true, quality: quality, custom: %W(-vf scale='#{width}:-1') }
      movie.transcode(path, options, transcoder_options)
    end
end
