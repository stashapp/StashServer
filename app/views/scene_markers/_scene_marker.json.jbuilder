json.(scene_marker, :id, :scene_id, :title, :seconds)
json.stream scene_markers_stream_path(scene_id: scene_marker.scene.id, id: scene_marker.id)
