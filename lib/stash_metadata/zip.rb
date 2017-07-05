module StashMetadata
  module Zip

    def self.extract zip:, index:, output: nil
      cache_key = "#{File.basename(zip)}_#{index}"
      unless Rails.cache.read(cache_key).nil? || output
        return Rails.cache.read(cache_key)
      else
        ::Zip::File.open(zip) do |zip_file|
          files = sorted_files(zip_file: zip_file)
          return nil unless index < files.count

          entry = files[index]
          if output
            entry.extract(output) if entry
          else
            data = entry.get_input_stream.read
            Rails.cache.write(cache_key, data)
            return data
          end
        end
      end
    end

    def self.thumb zip:, index:
      cache_key = "#{File.basename(zip)}_#{index}_thumb"
      cache_path = File.expand_path(ENV['stash_cache'])
      file_path = File.join(cache_path, cache_key)
      if File.exists?(file_path)
        return file_path
      else
        data = self.extract(zip: zip, index: index)
        image = MiniMagick::Image.read(data)
        image.resize('512x512')
        image.write(file_path)
        return file_path
      end
    end

    def self.files zip:
      ::Zip::File.open(zip) do |zip_file|
        files = sorted_files(zip_file: zip_file)
        return files
      end
    end

    private

    def self.sorted_files zip_file:
      files = zip_file.glob('**.jpg', File::FNM_CASEFOLD) + zip_file.glob('**.png', File::FNM_CASEFOLD) + zip_file.glob('**.gif', File::FNM_CASEFOLD)
      files = files.delete_if { |file| file.name.include? "__MACOSX"}
      return Naturally.sort_by(files, :name)
    end

  end
end
