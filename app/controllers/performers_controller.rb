class PerformersController < ApplicationController
  before_action :set_performer, only: [:show, :edit, :update]

  def index
    @performers = Performer.all.page params[:page]
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

  private

    def set_performer
      @performer = Performer.find(params[:id])
    end

    def performer_params
      params.fetch(:performer, {})
    end
end
