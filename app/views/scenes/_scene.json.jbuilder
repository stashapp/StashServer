json.(scene, :id, :checksum, :path, :title, :details, :url, :date, :rating, :size, :duration, :video_codec, :audio_codec, :width, :height, :studio_id)
json.is_streamable scene.is_streamable
json.screenshot_path screenshot_path(scene.id)
json.preview_path scene_preview_path(scene.id)
json.stream_path stream_path(scene.id)
json.tag_ids do
  json.array! scene.tags.pluck :id
end
json.performer_ids do
  json.array! scene.performers.pluck :id
end
