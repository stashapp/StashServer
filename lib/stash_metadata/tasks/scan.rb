module StashMetadata
  module Tasks
    module Scan

      def self.start
        FileUtils.mkdir_p(STASH_SCREENSHOTS_DIRECTORY) unless File.directory?(STASH_SCREENSHOTS_DIRECTORY)
        tmp_dir = File.join(STASH_SCREENSHOTS_DIRECTORY, 'tmp')
        FileUtils.mkdir_p(tmp_dir) unless File.directory?(tmp_dir)

        @manager = StashMetadata::Manager.instance
        @manager.current = 1

        glob_path = File.join(StashMetadata::STASH_DIRECTORY, "**", "*.{zip,m4v,mp4,mov,wmv}")
        scan_paths = Dir[glob_path]
        @manager.total = scan_paths.count
        StashMetadata.logger.info("Starting scan of #{scan_paths.count} files")
        scan_paths.each do |path|
          if File.extname(path) == '.zip'
            klass = Gallery
          else
            klass = Scene
          end

          item = klass.find_by(path: path)
          if item
            make_screenshots(path: item.path, checksum: item.checksum) if klass == Scene
            @manager.current += 1
            next # We already have this item in the database, keep going
          end

          StashMetadata.logger.info("#{path} not found.  Calculating checksum...")
          checksum = Digest::MD5.file(path).hexdigest
          StashMetadata.logger.debug("Checksum calculated: #{checksum}")

          make_screenshots(path: path, checksum: checksum) if klass == Scene

          item = klass.find_by(checksum: checksum)
          if item
            StashMetadata.logger.info("#{path} already exists.  Updating path...")
            @manager.log(message: "#{path} already exists.  Updating path...")
            item.path = path
            item.save
          else
            StashMetadata.logger.info("#{path} doesn't exist.  Creating new item...")
            @manager.log(message: "#{path} doesn't exist.  Creating new item...")
            item = klass.new(path: path, checksum: checksum)

            if klass == Scene
              video = StashMetadata::FFMPEG.metadata(path: path)
              item.size        = video.size
              item.duration    = video.duration
              item.video_codec = video.video_codec
              item.audio_codec = video.audio_codec
              item.width       = video.width
              item.height      = video.height
            end

            item.save
          end

          @manager.current += 1
        end
      end

      private

      def self.make_screenshots(path:, checksum:)
        thumb_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.thumb.jpg")
        normal_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.jpg")

        if File.exist?(thumb_path) && File.exist?(normal_path)
          StashMetadata.logger.debug("Screenshots already exist for #{path}.  Skipping...")
          return
        end

        movie = StashMetadata::FFMPEG.metadata(path: path)
        make_screenshot(movie: movie, path: thumb_path, quality: 5, width: 320)
        make_screenshot(movie: movie, path: normal_path, quality: 2, width: movie.width)
      end

      def self.make_screenshot(movie:, path:, quality:, width:)
        time = movie.duration * 0.2
        transcoder_options = { input_options: { v: 'quiet', ss: "#{time}" } }
        options = { screenshot: true, quality: quality, custom: %W(-vf scale='#{width}:-1') }
        movie.transcode(path, options, transcoder_options)
      end

    end
  end
end
