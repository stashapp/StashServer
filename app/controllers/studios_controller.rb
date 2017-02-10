class StudiosController < ApplicationController
  before_action :set_studio, only: [:show]

  def index
    @studios = Studio
                .search_for(params[:q])
                .page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @studios.to_json }
    end
  end

  def show
  end

  def new
    @studio = Studio.new
  end

  def create
    @studio = Studio.new(studio_params)
    respond_to do |format|
      if @studio.save
        format.html { redirect_to studios_path, notice: 'Studio was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  private

    def set_studio
      @studio = Studio.find(params[:id])
    end

    def studio_params
      params.fetch(:studio).permit(:name)
    end
end
