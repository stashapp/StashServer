class Scene < ApplicationRecord
  include Filterable
  include Taggable

  validates_presence_of :checksum, :path
  validates_uniqueness_of :checksum, :path

  has_and_belongs_to_many :performers
  has_one :gallery, as: :ownable, dependent: :nullify
  has_many :scene_markers, dependent: :destroy
  belongs_to :studio, optional: true, touch: true

  scoped_search on: [:title, :details, :path, :checksum]
  scoped_search relation: :scene_markers, on: :title

  default_scope { order(path: :asc) }
  scope :filter_studios, -> (studio_ids) { where studio_id: studio_ids }
  scope :filter_performers, -> (performer_ids) { joins(:performers).where('performers.id IN (?)', performer_ids).distinct }
  scope :filter_tags, -> (tag_ids) { joins(:tags).where('tags.id IN (?)', tag_ids).distinct }

  scope :rating, -> (rating) { where('rating = ?', rating) }
  scope :resolution, -> (resolution) {
    resolution = resolution.first if resolution.is_a?(Array)
    if resolution == '240p'
      where('height >= 240 AND height < 480')
    elsif resolution == '480p'
      where('height >= 480 AND height < 720')
    elsif resolution == '720p'
      where('height >= 720 AND height < 1080')
    elsif resolution == '1080p'
      where('height >= 1080 AND height < 2160')
    elsif resolution == '4k'
      where('height >= 2160')
    else
      where('height < 240')
    end
  }
  scope :has_markers, -> (has_markers) {
    has_markers = has_markers.first if has_markers.is_a?(Array)
    if has_markers == 'true'
      joins(:scene_markers).group('scenes.id').having('count(scene_id) > 0')
    else
      left_outer_joins(:scene_markers).where(scene_markers: {id: nil})
    end
  }
  scope :is_missing, -> (missing) {
    if missing.first == 'gallery'
      missing_gallery
    else
      where missing.first.to_sym => nil
    end
  }
  scope :studio_id, -> (studio_id) { where studio_id: studio_id }
  scope :tag_id, -> (tag_id) { joins(:tags).where('tags.id = ?', tag_id).distinct }

  scope :missing_gallery, -> () { joins('LEFT OUTER JOIN galleries ON galleries.ownable_id = scenes.id').where('galleries.ownable_id IS NULL') }

  def mime_type
    return Mime::Type.lookup_by_extension(File.extname(path).delete('.')).to_s
  end

  def is_streamable
    valid = mime_type == "video/quicktime" || mime_type == "video/mp4" || mime_type == "video/webm"

    if !valid
      transcode = File.join(StashMetadata::STASH_TRANSCODE_DIRECTORY, "#{self.checksum}.mp4")
      valid = File.exist?(transcode)
    end

    return valid
  end

  def stream_file_path
    file_path = path
    transcode = File.join(StashMetadata::STASH_TRANSCODE_DIRECTORY, "#{checksum}.mp4")
    if File.exist?(transcode)
      file_path = transcode
    end
    return file_path
  end

  def screenshot(seconds: nil, width: nil)
    cache_key = "#{checksum}"
    if seconds
      cache_key = cache_key + "_#{seconds}"
    end
    if width
      cache_key = cache_key + "_#{width}"
    end

    unless Rails.cache.read(cache_key).nil?
      return Rails.cache.read(cache_key)
    else
      data = StashMetadata::FFMPEG.screenshot(path: path, seconds: seconds, width: width)
      Rails.cache.write(cache_key, data)
      return data
    end
  end

  def chapter_vtt
    vtt = ["WEBVTT", ""]
    scene_markers.each do |scene_marker|
      vtt.push("#{get_vtt_time(scene_marker.seconds)} --> #{get_vtt_time(scene_marker.seconds)}")
      vtt.push(scene_marker.title)
      vtt.push("")
    end

    vtt.join("\n")
  end

  private

    def get_vtt_time(seconds)
      Time.at(seconds).gmtime.strftime('%H:%M:%S')
    end
end
