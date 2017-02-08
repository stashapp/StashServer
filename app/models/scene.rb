class Scene < ApplicationRecord
  include Filterable
  include Taggable

  has_and_belongs_to_many :performers
  has_one :gallery, as: :ownable
  belongs_to :studio, optional: true

  scoped_search on: [:title, :details, :path, :checksum]

  default_scope { order(path: :asc) }
  scope :filter_studios, -> (studio_ids) { where studio_id: studio_ids }
  scope :filter_performers, -> (performer_ids) { joins(:performers).where('performers.id IN (?)', performer_ids).distinct }
  scope :filter_tags, -> (tag_ids) { joins(:tags).where('tags.id IN (?)', tag_ids).distinct }
  scope :filter_rating, -> (rating) { where('rating >= ?', rating) }
  scope :filter_missing, -> (missing) { where missing.first.to_sym => nil }

  def mime_type
    return Mime::Type.lookup_by_extension(File.extname(path).delete('.')).to_s
  end

  def chapter_vtt
    # TODO Get real chapter markers working here
    markers = [100, 400, 800]
    messages = ["First message", "Seconds", "Third message here"]

    i = 0
    vtt = ["WEBVTT",""]
    markers.count do |seconds|
      vtt.push("#{get_vtt_time(seconds)} --> #{get_vtt_time(seconds)}")
      vtt.push(messages[i])
      vtt.push("")
      i = i + 1
    end

    vtt.join("\n")
  end

  private

    def get_vtt_time(seconds)
      Time.at(seconds).gmtime.strftime('%H:%M:%S')
    end
end
