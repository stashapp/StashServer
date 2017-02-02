class Gallery < ApplicationRecord
  belongs_to :ownable, polymorphic: true, optional: true
end
