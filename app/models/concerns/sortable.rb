module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sortable params, default:
      sort_direction = %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
      sort_column = self.column_names.include?(params[:sort]) ? params[:sort] : default
      reorder(sort_column + ' ' + sort_direction)
    end
  end
end
