class SceneMarkersController < ApplicationController
  before_action :set_scene, only: [:index, :create, :update, :destroy]
  before_action :set_scene_marker, only: [:destroy, :stream]

  # GET /markers
  def markers
    @scene_markers = SceneMarker.search_for(params[:q])
                                .sortable({}, default: 'title')
                                .group(:title).count.map { |e| {title: e[0], count: e[1]} }
    @scene_markers.sort_by! { |e| e[:count] }.reverse! if params[:sort] == 'count'
  end

  # GET /markers/wall
  def wall
    @scene_markers = SceneMarker.search_for(params[:q]).limit(20).reorder('RANDOM()')
  end

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

  # GET /scenes/:scene_id/scene_markers/:id/stream
  def stream
    send_file @scene_marker.stream_file_path, disposition: 'inline'
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
