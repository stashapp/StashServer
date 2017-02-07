class Performer < ApplicationRecord
  has_and_belongs_to_many :scenes

  validate :image_exists

  scoped_search on: [:name, :checksum]

  default_scope { order(name: :asc) }

  private

  def image_exists
    errors.add(:image, "is empty") unless image
  end
end
