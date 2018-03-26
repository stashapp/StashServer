class ScrapedItem < ApplicationRecord
  belongs_to :studio

  validates :title, :url, :date, :video_filename, presence: true

  def scene
    scenes = Scene.where('path like ?', "%/#{video_filename}").select { |scene| scene.studio.nil? || scene.studio.id == studio.id }
    if scenes.count == 1
      return scenes.first
    elsif scenes.count > 1
      scenes = Scene.where('path like ?', "%#{studio.name}%/#{video_filename}")
      return scenes.first if scenes.count == 1
    else
      return nil
    end
  end

  def gallery
    return nil if scene.nil? || gallery_filename.blank?
    scene_path = File.dirname(scene.path)
    gallery_path = File.join(scene_path, gallery_filename)
    return Gallery.find_by(path: gallery_path)
  end

  def populate_scene(the_scene = nil)
    the_scene = scene if the_scene.nil?
    return if the_scene.nil?

    details = ""
    valid_tags = []
    valid_models = []
    if !description.blank?
      details += "#{description}\n\n"
    end
    if !rating.blank?
      details += "Rating: #{rating}\n"
    end
    if !tags.blank?
      details += "Tags: #{tags}\n"
      valid_tags = tags.split(', ').map { |tag|
        next if tag.strip.titleize == 'Sexy'
        Tag.where(name: tag.strip.titleize).first
      }.compact
    end
    if !models.blank?
      details += "Models: #{models}"
      model_names = models.split(', ')
      model_objects = model_names.map { |model_name| Performer.where(name: model_name.strip.titleize).first }.compact
      valid_models = model_objects if model_objects.count == model_names.count
    end

    if title.include?('-')
      the_scene.title = title
    else
      the_scene.title = title.titleize
    end
    the_scene.url = url
    the_scene.date = date
    the_scene.tags = valid_tags unless the_scene.tags.count > 0
    the_scene.performers = valid_models unless the_scene.performers.count > 0
    the_scene.details = details
    byebug if !the_scene.gallery.nil? && !gallery.nil? && the_scene.gallery.id != gallery.id
    the_scene.gallery = gallery
    byebug if !the_scene.studio.nil? && the_scene.studio.id != studio.id
    the_scene.studio = studio

    the_scene.save
  end
end
