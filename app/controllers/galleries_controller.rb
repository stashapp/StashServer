class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:show, :file]

  def index
    @galleries = Gallery
                  .search_for(params[:q])
                  .page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @galleries.to_json }
    end
  end

  def show
    per_page = 30
    files = @gallery.files
    @images = Kaminari.paginate_array(files).page(params[:page]).per(per_page)
    @count = files.count
    if params[:page] && params[:page].to_i > 1
      i = params[:page].to_i - 1
      @offset = per_page * i
    else
      @offset = 0
    end
  end

  def file
    data = StashMetadata::Zip.extract(zip: @gallery.path, index: params[:index].to_i)
    if data
      send_data data, type: 'image/jpg', disposition: 'inline' # TODO Correct mime type
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

    def set_gallery
      @gallery = Gallery.find(params[:id])
    end

    def gallery_params
      params.fetch(:gallery, {})
    end

end
