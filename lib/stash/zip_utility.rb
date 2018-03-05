module Stash::ZipUtility

  def self.get_image(gallery:, index:)
    extract(gallery)
    file = gallery.files[index]
    return File.join(Stash::STASH_CACHE_DIRECTORY, gallery.checksum, file.name)
  end

  def self.get_thumbnail(gallery:, index:)
    extract(gallery)
    file = gallery.files[index]

    basename = File.basename(file.name, '.*')
    thumbnail_name = file.name.sub(basename, "#{basename}_thumb")
    thumbnail_file_path = File.join(Stash::STASH_CACHE_DIRECTORY, gallery.checksum, thumbnail_name)
    return thumbnail_file_path if File.exists?(thumbnail_file_path)

    file_path = File.join(Stash::STASH_CACHE_DIRECTORY, gallery.checksum, file.name)
    image = MiniMagick::Image.open(file_path)
    image.resize('512x512')
    image.write(thumbnail_file_path)
    return thumbnail_file_path
  end

  def self.get_files(zip)
    Zip::File.open(zip) do |zip_file|
      return sorted(zip_file)
    end
  end

  private

    def self.sorted(zip_file)
      files = zip_file.glob('**.jpg', File::FNM_CASEFOLD) + zip_file.glob('**.png', File::FNM_CASEFOLD) + zip_file.glob('**.gif', File::FNM_CASEFOLD)
      files = files.delete_if { |file| file.name.include? "__MACOSX" }
      return Naturally.sort_by(files, :name)
    end

    def self.extract(gallery)
      gallery_cache_path = File.join(Stash::STASH_CACHE_DIRECTORY, gallery.checksum)
      FileUtils.mkdir_p(Stash::STASH_CACHE_DIRECTORY) unless File.directory?(Stash::STASH_CACHE_DIRECTORY)
      FileUtils.mkdir_p(gallery_cache_path) unless File.directory?(gallery_cache_path)
      return if Dir["#{gallery_cache_path}/**/*"].count == gallery.files.count

      Zip::File.open(gallery.path) do |zip_file|
        files = sorted(zip_file)
        files.each { |file|
          file_path = File.join(gallery_cache_path, file.name)

          unless File.exist?(file_path)
            FileUtils.mkdir_p(File.dirname(file_path))
            file.extract(file_path)
          end
        }
      end
    end
end
