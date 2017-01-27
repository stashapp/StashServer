class Scene < ApplicationRecord
  has_and_belongs_to_many :performers
  belongs_to :studio, optional: true

  def mime_type
    return Mime::Type.lookup_by_extension(File.extname(path).delete('.')).to_s
  end
end
