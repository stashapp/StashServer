require 'mini_magick'

class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:file]

  def file
    index = params[:index].to_i
    file = @gallery.files[index]

    if params[:thumb]
      file_path = Stash::ZipUtility.get_thumbnail(gallery: @gallery, index: index)
      raise ActionController::RoutingError.new('Not Found') unless file_path
      send_file file_path, filename: file.name, disposition: 'inline'
    else
      file_path = Stash::ZipUtility.get_image(gallery: @gallery, index: index)
      raise ActionController::RoutingError.new('Not Found') unless file_path
      send_file file_path, filename: file.name, disposition: 'inline'
    end
  end

  private

    def set_gallery
      @gallery = Gallery.find(params[:id])
    end

    def gallery_params
      params.fetch(:gallery).permit(:title, performer_ids: [])
    end

end
