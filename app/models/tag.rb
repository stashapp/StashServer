class Tag < ApplicationRecord
  has_many :taggings
  has_many :scenes, through: :taggings, source: :taggable, source_type: 'Scene'

  has_many :scene_markers, through: :taggings, source: :taggable, source_type: 'SceneMarker'
  has_many :primary_scene_markers, class_name: 'SceneMarker', foreign_key: :primary_tag_id

  scoped_search on: [:name]

  default_scope { order(name: :asc) }
end
