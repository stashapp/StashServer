class StudiosController < ApplicationController
  before_action :set_studio, only: [:show, :edit, :update]

  def index
    @studios = Studio.all.page params[:page]
    respond_to do |format|
      format.html
      format.json { render json: @studios.to_json }
    end
  end

  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @studio.update(scene_params)
        format.html { redirect_to @studio, notice: 'Studio was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

    def set_studio
      @studio = Studio.find(params[:id])
    end

    def studio_params
      params.fetch(:studio, {})
    end
end
