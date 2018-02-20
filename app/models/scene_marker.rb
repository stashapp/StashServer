class SceneMarker < ApplicationRecord
  belongs_to :scene, touch: true
  default_scope { order(seconds: :asc) }
  scoped_search on: [:title, :scene_id]

  validates :title, presence: true
  validates :seconds, numericality: { only_integer: true }

  def stream_file_path
    return File.join(StashMetadata::STASH_TRANSCODE_DIRECTORY, scene.checksum, "#{seconds.to_i}.mp4")
  end

  def stream_preview_path
    return File.join(StashMetadata::STASH_TRANSCODE_DIRECTORY, scene.checksum, "#{seconds.to_i}.webp")
  end
end
