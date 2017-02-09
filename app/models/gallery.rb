class Gallery < ApplicationRecord
  has_and_belongs_to_many :performers
  belongs_to :ownable, polymorphic: true, optional: true

  scoped_search on: [:title, :checksum]

  def files
    StashMetadata::Zip.files(zip: self.path)
  end
end
