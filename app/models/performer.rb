class Performer < ApplicationRecord
  has_and_belongs_to_many :scenes
  has_and_belongs_to_many :galleries

  validate :image_exists

  scoped_search on: [:name, :checksum, :birthdate]

  default_scope { order(name: :asc) }

  private

  def image_exists
    errors.add(:image, "is empty") unless image
  end
end
