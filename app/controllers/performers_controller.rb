require 'base64'

class PerformersController < ApplicationController
  before_action :set_performer, only: [:show, :edit, :update, :image]

  def index
    @performers = Performer
                    .search_for(params[:q])
                    .page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @performers.to_json }
    end
  end

  def show
  end

  def edit
    glob_path = File.join(StashMetadata::STASH_DIRECTORY, "*", "*.{jpg}")
    glob = Dir[glob_path]
    @files = []
    glob.each do |file|
      file = {data: Base64.encode64(open(file).to_a.join), path: file}
      @files.push(file)
    end
  end

  def update
    @performer.attributes = performer_params
    if params[:image_path] && params[:image_path].start_with?(StashMetadata::STASH_DIRECTORY)
      checksum = Digest::MD5.file(params[:image_path]).hexdigest
      @performer.image = File.read(params[:image_path])
      @performer.checksum = checksum
    end

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
      params.fetch(:performer).permit(:name, :url)
    end
end
