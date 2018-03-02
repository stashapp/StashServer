class Studio < ApplicationRecord
  # Relations
  has_many :scenes

  scoped_search on: [:name]

  default_scope { order(name: :asc) }

  # Validations
  validates_presence_of :name, :checksum
  validates_uniqueness_of :name, :checksum
  validate :image_exists

  private

    def image_exists
      errors.add(:image, "is empty") unless image
    end
end
