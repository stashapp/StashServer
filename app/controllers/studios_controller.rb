require 'filemagic'

class StudiosController < ApplicationController

  before_action :set_studio, only: [:image]

  def image
    if stale?(@studio)
      type = FileMagic.new(FileMagic::MAGIC_MIME).buffer(@studio.image)

      expires_in 1.week
      response.headers['Content-Length'] = @studio.image.bytesize.to_s
      send_data @studio.image, disposition: 'inline', type: type
    end
  end

  private

    def set_studio
      @studio = Studio.find(params[:id])
    end
end
