class Performer < ApplicationRecord
  has_and_belongs_to_many :scenes
end
