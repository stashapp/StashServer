module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sortable(parameters, default:)
      params = parameters.symbolize_keys
      params[:sort] = default if params[:sort].nil?
      sort_direction = %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
      sort_column = self.column_names.include?(params[:sort]) ? params[:sort] : default

      if params[:sort].include?('_count')
        t_name = params[:sort].split('_').first.pluralize
        left_joins(t_name.to_sym).group(:id).reorder("COUNT(#{t_name}.id) #{sort_direction}")
      elsif params[:sort] == 'filesize'
        reorder("cast(#{table_name}.size as integer) #{sort_direction}")
      else
        reorder("#{table_name}.#{sort_column}" + ' ' + sort_direction)
      end
    end
  end
end
