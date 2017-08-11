class ApplicationRecord < ActiveRecord::Base
  include Pageable
  include Sortable
  self.abstract_class = true
end
