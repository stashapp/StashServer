class Gallery < ApplicationRecord
  has_and_belongs_to_many :performers
  belongs_to :ownable, polymorphic: true, optional: true

  scoped_search on: [:title, :checksum, :path]

  scope :unowned, -> () { where ownable_id: nil }
  scope :unowned_in_path, -> (path) { unowned.where('path like ?', "%#{path}%") }

  def files
    Stash::ZipUtility.get_files(self.path)
  end
end
