require 'filemagic'

class StudiosController < ApplicationController
  include ImageProcessor

  before_action :set_studio, only: [:show, :update, :destroy, :image]

  # GET /studios
  def index
    @studios = Studio
                .search_for(params[:q])
                .sortable(params, default: 'name')
                .pageable(params)
  end

  # POST /studios
  def create
    @studio = Studio.new
    @studio.attributes = studio_params
    process_image(params: params, object: @studio)
    @studio.save!
    render status: :created
  end

  # GET /studios/:id
  def show
    fresh_when(@studio)
    expires_in 10.minute
  end

  # PUT/PATCH /studios/:id
  def update
    @studio.attributes = studio_params
    process_image(params: params, object: @studio)
    @studio.save!
    head :no_content
  end

  # DELETE /studios/:id
  def destroy
    @studio.destroy
    head :no_content
  end

  def image
    if stale?(@studio)
      type = FileMagic.new(FileMagic::MAGIC_MIME).buffer(@studio.image)

      expires_in 1.week
      response.headers['Content-Length'] = @studio.image.size.to_s
      send_data @studio.image, disposition: 'inline', type: type
    end
  end

  private

  def studio_params
    params.permit(:name, :url)
  end

  def set_studio
    @studio = Studio.find(params[:id])
  end
end
