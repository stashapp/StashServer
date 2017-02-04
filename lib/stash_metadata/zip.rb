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
