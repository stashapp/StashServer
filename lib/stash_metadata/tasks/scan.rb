module StashMetadata
  module Tasks
    module Scan

      def self.start
        glob_path = File.join(StashMetadata::STASH_DIRECTORY, "**", "*.{mp4,mov,wmv,zip}")
        scan_paths = Dir[glob_path]
        StashMetadata.logger.info("Starting scan of #{scan_paths.count} files")
        scan_paths.each do |path|
          if File.extname(path) == '.zip'
            klass = Gallery
          else
            klass = Scene
          end

          item = klass.find_by(path: path)
          if item
            make_screenshots(path: item.path, checksum: item.checksum)
            next # We already have this item in the database, keep going
          end

          StashMetadata.logger.info("#{path} not found.  Calculating checksum...")
          checksum = Digest::MD5.file(path).hexdigest
          StashMetadata.logger.debug("Checksum calculated: #{checksum}")

          make_screenshots(path: path, checksum: checksum)

          item = klass.find_by(checksum: checksum)
          if item
            StashMetadata.logger.info("#{path} already exists.  Updating path...")
            item.path = path
            item.save
          else
            StashMetadata.logger.info("#{path} doesn't exist.  Creating new item...")
            klass.create(path: path, checksum: checksum)
          end
        end
      end

      private

      def self.make_screenshots(path:, checksum:)
        thumb_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.thumb.jpg")
        normal_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.jpg")
        zip_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{checksum}.zip.jpg") # TODO Assuming JPG here...

        if File.extname(path) == '.zip'
          if File.exist?(zip_path)
            StashMetadata.logger.debug("Screenshot already exist for #{path}.  Skipping...")
            return
          end

          StashMetadata::Zip.extract(zip: path, index: 0, output: zip_path)
        else
          if File.exist?(thumb_path) && File.exist?(normal_path)
            StashMetadata.logger.debug("Screenshots already exist for #{path}.  Skipping...")
            return
          end

          movie = FFMPEG::Movie.new(path)
          make_screenshot(movie: movie, path: thumb_path, quality: 5, width: 320)
          make_screenshot(movie: movie, path: normal_path, quality: 2, width: movie.width)
        end
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
