class SceneMarkersController < ApplicationController
  before_action :set_scene, only: [:index, :create, :update, :destroy]
  before_action :set_scene_marker, only: [:destroy]

  # GET /scenes/:scene_id/scene_markers
  def index
  end

  # POST /scenes/:scene_id/scene_markers
  def create
    @scene_marker = @scene.scene_markers.create(scene_marker_params)
    render status: :created
  end

  # DELETE /scenes/:scene_id/scene_markers/:id
  def destroy
    @scene_marker.destroy
    head :no_content
  end

  private

  def scene_marker_params
    params.permit(:title, :seconds)
  end

  def set_scene
    @scene = Scene.find(params[:scene_id])
  end

  def set_scene_marker
    @scene_marker = SceneMarker.find(params[:id])
  end
end
