class Performer < ApplicationRecord
  has_and_belongs_to_many :scenes
  has_and_belongs_to_many :galleries

  validate :image_exists

  scoped_search on: [:name, :checksum, :birthdate]

  default_scope { order(name: :asc) }

  def age(date: Date.today)
    a = date.year - birthdate.year
    a = a - 1 if (birthdate.month > date.month || (birthdate.month >= date.month && birthdate.day > date.day))
    return a
  end

  private

  def image_exists
    errors.add(:image, "is empty") unless image
  end
end
