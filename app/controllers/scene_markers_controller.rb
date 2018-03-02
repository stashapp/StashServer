class SceneMarkersController < ApplicationController
  before_action :set_scene, only: [:index, :create, :update, :destroy]
  before_action :set_scene_marker, only: [:destroy, :stream, :preview]

  # GET /scenes/:scene_id/scene_markers/:id/stream
  def stream
    send_file @scene_marker.stream_file_path, disposition: 'inline'
  end

  # GET /scenes/:scene_id/scene_markers/:id/preview
  def preview
    send_file @scene_marker.stream_preview_path, disposition: 'inline'
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
