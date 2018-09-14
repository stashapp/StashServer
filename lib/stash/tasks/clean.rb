class Stash::Tasks::Clean < Stash::Tasks::Base
  def initialize
    super()
  end

  def start
    remove_deleted
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


    def remove_deleted
      @manager.info("Removing metadata for deleted media")

      Scene.all.each do |scene|
        unless scene.media_exists?
          @manager.info("Scene #{scene.path} no longer exists.")
          scene.destroy
        end
      end
    end
end
