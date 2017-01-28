class Studio < ApplicationRecord
  has_many :scenes

  scoped_search on: [:name]

  default_scope { order(name: :desc) }
end
