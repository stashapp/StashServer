module StashMetadata
  module Tasks
    module Cleanup

      def self.start
        self.clean_directory(STASH_SCREENSHOTS_DIRECTORY)
        self.clean_directory(STASH_VTT_DIRECTORY)
        self.clean_directory(STASH_TRANSCODE_DIRECTORY)
      end


      def self.clean_directory(dir)
        StashMetadata.logger.info("Cleaning #{dir}")

        Dir.foreach(dir) { |f|
          if /([a-f0-9]{32})/.match(f)
            unless Scene.exists?(checksum: $1)
              StashMetadata.logger.info("Scene for checksum no longer exists: #{$1}")
              FileUtils.rm_r [File.join(dir, f)]
            end
          end
        }
      end

    end
  end
end
