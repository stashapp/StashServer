class ScenesController < ApplicationController
  before_action :set_scene, only: [:show, :edit, :update]

  def index
    @scenes = Scene.all
  end

  def show
  end

  # GET /scenes/1/edit
  def edit
  end

  # PATCH/PUT /scenes/1
  def update
    respond_to do |format|
      if @scene.update(scene_params)
        format.html { redirect_to @scene, notice: 'Scene was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_scene
      @scene = Scene.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scene_params
      params.fetch(:scene, {})
    end
end
