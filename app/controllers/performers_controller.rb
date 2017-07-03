class PerformersController < ApplicationController
  include ServerImages

  before_action :set_performer, only: [:show, :edit, :update, :image]

  def index
    whitelist = params.slice(:filter_favorites)
    @performers = Performer
                    .search_for(params[:q])
                    .filter(whitelist)
                    .page(params[:page])
                    .per(params[:per_page])
  end

  def show
  end

  def new
    @performer = Performer.new
  end

  def create
    @performer = Performer.new
    @performer.attributes = performer_params
    update_image

    respond_to do |format|
      if @performer.save
        format.html { redirect_to @performer, notice: 'Performer was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def update
    @performer.attributes = performer_params
    update_image

    respond_to do |format|
      if @performer.save
        format.html { redirect_to @performer, notice: 'Performer was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def image
    send_data @performer.image, disposition: 'inline'
  end

  private

    def set_performer
      @performer = Performer.find(params[:id])
    end

    def performer_params
      params.fetch(:performer).permit(:name, :url, :birthdate, :ethnicity, :country, :eye_color, :height, :measurements, :fake_tits, :career_length, :tattoos, :piercings, :aliases, :twitter, :instagram, :favorite)
    end

    def update_image
      if params[:image_path] && params[:image_path].start_with?(StashMetadata::STASH_DIRECTORY)
        checksum = Digest::MD5.file(params[:image_path]).hexdigest
        @performer.image = File.read(params[:image_path])
        @performer.checksum = checksum
      end
    end
end
