class SceneMarker < ApplicationRecord
  include Filterable
  include Taggable

  belongs_to :primary_tag, class_name: 'Tag'

  belongs_to :scene, touch: true
  default_scope { order(seconds: :asc) }

  scoped_search on: [:title, :scene_id]
  scoped_search relation: :scene, on: :title
  # scoped_search relation: :primary_tag, on: :name
  # scoped_search relation: :tags, on: :name

  validates :title, presence: true
  validates :seconds, numericality: true

  def self.tag_id(tag_id)
    tag_id = tag_id.first if tag_id.is_a? Array

    SceneMarker.left_outer_joins(:tags)
               .where("'scene_markers'.'primary_tag_id' = :tag_id OR 'tags'.'id' = :tag_id", tag_id: tag_id)
               .distinct
  end

  scope :tags, -> (tag_ids) {
    tag_ids = tag_ids.map { |id| id.to_i  }.uniq

    markers = left_outer_joins(:tags)
                .where(:scene_markers => {:primary_tag_id => tag_ids})
                .distinct

    ids = []
    if markers.count == 0
      return left_outer_joins(:tags)
                .where(:tags => {:id => tag_ids})
                .group("scene_markers.id")
                .having("count(taggings.tag_id) = #{tag_ids.length}")
                .unscope(:order)
                .distinct
    else
      ids += left_outer_joins(:tags)
                .where(:tags => {:id => tag_ids})
                .group("scene_markers.id")
                .having("count(taggings.tag_id) = #{tag_ids.length}")
                .unscope(:order)
                .distinct
                .pluck(:id)
    end

    markers.each { |marker|
      difference = tag_ids - [marker.primary_tag_id]
      difference = difference - marker.tags.pluck(:id)

      ids << marker.id if difference.length == 0
    }

    where(id: ids.uniq)
  }

  def stream_file_path
    return File.join(Stash::STASH_MARKERS_DIRECTORY, scene.checksum, "#{seconds.to_i}.mp4")
  end

  def stream_preview_path
    return File.join(Stash::STASH_MARKERS_DIRECTORY, scene.checksum, "#{seconds.to_i}.webp")
  end
end
