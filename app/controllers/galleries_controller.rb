require 'mini_magick'

class GalleriesController < ApplicationController
  before_action :set_gallery, only: [:file]

  def file
    if stale?(@gallery)
      index = params[:index].to_i
      file = @gallery.files[index]

      file_path = nil
      if params[:thumb]
        file_path = Stash::ZipUtility.get_thumbnail(gallery: @gallery, index: index)
      else
        file_path = Stash::ZipUtility.get_image(gallery: @gallery, index: index)
      end

      raise ActionController::RoutingError.new('Not Found') unless file_path

      type = FileMagic.new(FileMagic::MAGIC_MIME).file(file_path)
      expires_in 1.week
      response.headers['Content-Length'] = File.size(file_path).to_s

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
