class Scene < ApplicationRecord
  include Filterable

  has_and_belongs_to_many :performers
  belongs_to :studio, optional: true

  scoped_search on: [:title, :details, :path, :checksum]

  default_scope { order(path: :desc) }
  scope :filter_studios, -> (studio_ids) { where studio_id: studio_ids }
  scope :filter_performers, -> (performer_ids) { joins(:performers).where('performers.id IN (?)', performer_ids).distinct }

  def mime_type
    return Mime::Type.lookup_by_extension(File.extname(path).delete('.')).to_s
  end
end
