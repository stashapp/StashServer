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
  end

  def update
    respond_to do |format|
      if @performer.update(scene_params)
        format.html { redirect_to @performer, notice: 'Performer was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  def image
    # TODO Handle more than JPG
    path = File.join(ENV['HOME'], "/.stash/performers/#{@performer.checksum}.jpg")
    send_file path, disposition: 'inline'
  end

  private

    def set_performer
      @performer = Performer.find(params[:id])
    end

    def performer_params
      params.fetch(:performer, {})
    end
end
