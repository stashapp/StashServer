class Scene < ApplicationRecord
  has_and_belongs_to_many :performers
  belongs_to :studio, optional: true
end
