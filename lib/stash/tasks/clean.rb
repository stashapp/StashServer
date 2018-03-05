class Stash::Tasks::Clean < Stash::Tasks::Base
  def initialize
    super
  end

  def start
    clean_directory(Stash::STASH_SCREENSHOTS_DIRECTORY)
    clean_directory(Stash::STASH_VTT_DIRECTORY)
    clean_directory(Stash::STASH_TRANSCODE_DIRECTORY)
    return nil
  end

  private

    def clean_directory(dir)
      @manager.info("Cleaning #{dir}")

      Dir.foreach(dir) { |f|
        if /([a-f0-9]{32})/.match(f)
          unless Scene.exists?(checksum: $1)
            @manager.info("Scene for checksum no longer exists: #{$1}")
            FileUtils.rm_r [File.join(dir, f)]
          end
        end
      }
    end
end
