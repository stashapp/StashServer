require 'filemagic'

class PerformersController < ApplicationController

  before_action :set_performer, only: [:image]

  def image
    if stale?(@performer)
      type = FileMagic.new(FileMagic::MAGIC_MIME).buffer(@performer.image)

      expires_in 1.week
      response.headers['Content-Length'] = @performer.image.bytesize.to_s
      send_data @performer.image, disposition: 'inline', type: type
    end
  end

  private

    def set_performer
      @performer = Performer.find(params[:id])
    end
end
