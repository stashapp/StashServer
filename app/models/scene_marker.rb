class SceneMarker < ApplicationRecord
  belongs_to :scene
  default_scope { order(seconds: :asc) }
  scoped_search on: [:title, :scene_id]

  def stream_file_path
    return File.join(StashMetadata::STASH_TRANSCODE_DIRECTORY, scene.checksum, "#{seconds.to_i}.mp4")
  end
end
