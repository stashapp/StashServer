require 'filemagic'

class PerformersController < ApplicationController
  include ImageProcessor

  before_action :set_performer, only: [:show, :update, :image]

  def index
    whitelist = params.slice(:filter_favorites)
    @performers = Performer
                    .search_for(params[:q])
                    .filter(whitelist)
                    .sortable(params, default: 'name')
                    .pageable(params)
  end

  def show
    fresh_when(@performer)
    expires_in 10.minute
  end

  def create
    @performer = Performer.new
    @performer.attributes = performer_params
    process_image(params: params, object: @performer)
    @performer.save!
  end

  def update
    @performer.attributes = performer_params
    process_image(params: params, object: @performer)
    @performer.save!
  end

  def image
    if stale?(@performer)
      type = FileMagic.new(FileMagic::MAGIC_MIME).buffer(@performer.image)

      expires_in 1.week
      response.headers['Content-Length'] = @performer.image.size.to_s
      send_data @performer.image, disposition: 'inline', type: type
    end
  end

  private

    def set_performer
      @performer = Performer.find(params[:id])
    end

    def performer_params
      params.permit(:name, :url, :birthdate, :ethnicity, :country, :eye_color, :height, :measurements, :fake_tits, :career_length, :tattoos, :piercings, :aliases, :twitter, :instagram, :favorite)
    end
end
