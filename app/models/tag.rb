class Tag < ApplicationRecord
  has_many :taggings
  has_many :scenes, through: :taggings, source: :taggable, source_type: 'Scene'

  scoped_search on: [:name]

  default_scope { order(name: :asc) }
end
