module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
  end

  def tag_list
    tags.map(&:name)
  end

  def has_tag(tag_name)
    Tag.where(name: tag_name.strip).first
  end

  def add_tag(tag_name)
    tag = Tag.where(name: tag_name.strip).first_or_create!
    if !tags.find_by(id: tag.id)
      tags << tag
      touch if persisted?
    end
  end

  def remove_tag(tag_name)
    tag = has_tag(tag_name)
    if tag
      tags.destroy(tag)
      touch if persisted?
    end
  end

  def remove_all_tags
    tags.destroy_all
    touch if persisted?
  end

  def all_tags=(names)
    self.tags = names.split(",").map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end

end
