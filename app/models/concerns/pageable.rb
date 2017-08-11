module Pageable
  extend ActiveSupport::Concern

  module ClassMethods
    def pageable params
      if params[:all]
        params[:page] = 1
        params[:per_page] = self.count
      end
      page(params[:page]).per(params[:per_page])
    end
  end
end
