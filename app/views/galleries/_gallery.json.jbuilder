json.(gallery, :id, :checksum, :path, :title)
if defined? show_files
  json.files gallery.files.map.with_index { |file, i| {index: i, name: file.name, path: gallery_file_path(gallery, index: i)} }
end
