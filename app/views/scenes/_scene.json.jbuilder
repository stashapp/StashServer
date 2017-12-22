json.(scene, :id, :checksum, :path, :title, :details, :url, :date, :rating)
json.file do
  json.(scene, :size, :duration, :video_codec, :audio_codec, :width, :height)
end
json.paths do
  json.screenshot screenshot_path(scene.id)
  json.preview scene_preview_path(scene.id)
  json.stream stream_path(scene.id)
  json.webp scene_webp_path(scene.id)
  json.vtt scene_path(scene.checksum) + "_thumbs.vtt"
  json.chapters_vtt scene_chapter_vtt_path(scene.id)
end
json.is_streamable scene.is_streamable
json.scene_markers do
  json.array! scene.scene_markers, partial: 'scene_markers/scene_marker', as: :scene_marker
end
json.gallery_id(scene.gallery.id) unless scene.gallery.nil?
json.studio_id scene.studio_id
json.tag_ids do
  json.array! scene.tags.pluck :id
end
json.performer_ids do
  json.array! scene.performers.pluck :id
end
