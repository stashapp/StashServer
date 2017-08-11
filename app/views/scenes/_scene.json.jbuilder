json.(scene, :id, :checksum, :path, :title, :details, :url, :date, :rating)
json.file do
  json.(scene, :size, :duration, :video_codec, :audio_codec, :width, :height)
end
json.paths do
  json.screenshot screenshot_path(scene.id)
  json.preview scene_preview_path(scene.id)
  json.stream stream_path(scene.id)
  json.vtt scene_path(scene.checksum) + "_thumbs.vtt"
end
json.is_streamable scene.is_streamable
json.gallery_id(scene.gallery.id) unless scene.gallery.nil?
json.studio_id scene.studio_id
json.tag_ids do
  json.array! scene.tags.pluck :id
end
json.performer_ids do
  json.array! scene.performers.pluck :id
end
