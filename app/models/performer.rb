class Performer < ApplicationRecord
  has_and_belongs_to_many :scenes

  scoped_search on: [:name, :checksum]

  default_scope { order(name: :asc) }
end
