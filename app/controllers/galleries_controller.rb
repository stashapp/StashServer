require 'mini_magick'

class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:show, :edit, :update, :file]
  before_action :split_commas, only: [:update]

  def index
    @galleries = Gallery
                  .search_for(params[:q])
                  .sortable(params, default: 'path')
                  .pageable(params)

    if params[:scene_id]
      scene = Scene.find(params[:scene_id])
      @galleries = Gallery.unowned.select { |gallery| gallery.path.include?(File.dirname(scene.path)) }
      @galleries.push(scene.gallery) unless scene.gallery.nil?
    end
  end

  def show
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

    if params[:thumb]
      file_path = StashMetadata::Zip.thumb(zip: @gallery.path, index: index)
      raise ActionController::RoutingError.new('Not Found') unless file_path
      send_file file_path, filename: file.name, disposition: 'inline'
    else
      data = StashMetadata::Zip.extract(zip: @gallery.path, index: index)
      raise ActionController::RoutingError.new('Not Found') unless data
      send_data data, filename: file.name, disposition: 'inline'
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
