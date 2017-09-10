class SceneMarker < ApplicationRecord
  belongs_to :scene
  default_scope { order(seconds: :asc) }
end
