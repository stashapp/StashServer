class ScenesController < ApplicationController
  before_action :set_scene, only: [:show, :edit, :update, :stream, :screenshot, :preview, :vtt, :chapter_vtt, :playlist]

  def index
    whitelist = params.slice(:rating, :resolution, :has_markers, :studio_id, :tag_id)
    @scenes = Scene
                .search_for(params[:q])
                .filter(whitelist)
                .sortable(params, default: 'path')
                .pageable(params)
  end

  def show
  end

  # PATCH/PUT /scenes/1
  def update
    @scene.attributes = scene_params

    if params[:gallery_id]
      if params[:gallery_id] != 0
        @scene.gallery = Gallery.find(params[:gallery_id])
      else
        @scene.gallery = nil
      end
    end

    @scene.save!
  end

  def wall
    @scenes = Scene.search_for(params[:q]).limit(20).reorder('RANDOM()')
  end

  def stream
    send_file @scene.stream_file_path, disposition: 'inline'
  end

  def screenshot
    path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.jpg")
    thumb_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.thumb.jpg")

    if params[:seconds]
      data = @scene.screenshot(seconds: params[:seconds], width: params[:width])
      send_data data, filename: 'screenshot.jpg', disposition: 'inline'
    elsif File.exist?(thumb_path) && params[:width] && params[:width].to_i < 400
      send_file thumb_path, disposition: 'inline'
    else
      send_file path, disposition: 'inline'
    end
  end

  def preview
    path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.webm")
    if File.exist?(path)
      send_file path, disposition: 'inline'
    else
      # TODO: custom exception
      render json: {}, status: :not_found
    end
  end

  def vtt
    path = ''
    if params[:format] == :jpg
      path = File.join(StashMetadata::STASH_VTT_DIRECTORY, "#{@scene.checksum}_sprite.jpg")
    else
      path = File.join(StashMetadata::STASH_VTT_DIRECTORY, "#{@scene.checksum}_thumbs.vtt")
    end

    send_file path, disposition: 'inline'
  end

  def chapter_vtt
    render inline: @scene.chapter_vtt
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_scene
      if params[:id].include? '.vtt'
        params[:id].slice! '_thumbs.vtt'
        params[:format] = :vtt
      end
      if params[:id].include? '.jpg'
        params[:id].slice! '_sprite.jpg'
        params[:format] = :jpg
      end

      if Scene.find_by(checksum: params[:id])
        @scene = Scene.find_by(checksum: params[:id])
      else
        @scene = Scene.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scene_params
      params.permit(:title, :details, :url, :date, :rating, :studio_id, performer_ids: [], tag_ids: [])
    end

end
