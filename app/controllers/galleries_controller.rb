class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:show, :edit, :update, :file]
  before_action :split_commas, only: [:update]

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

  def edit
  end

  def update
    respond_to do |format|
      if @gallery.update(gallery_params)
        format.html { redirect_to @gallery, notice: 'Gallery was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def file
    index = params[:index].to_i
    file = @gallery.files[index]
    data = StashMetadata::Zip.extract(zip: @gallery.path, index: index)
    if data
      send_data data, filename: file.name, disposition: 'inline'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  private

    def set_gallery
      @gallery = Gallery.find(params[:id])
    end

    def gallery_params
      params.fetch(:gallery).permit(:title, performer_ids: [])
    end

    def split_commas
      if params[:gallery]
        params[:gallery][:performer_ids] = params[:gallery][:performer_ids].split(",") if params[:gallery][:performer_ids]
      end
    end

end
