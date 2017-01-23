class Scene < ApplicationRecord
  has_and_belongs_to_many :performers
end
