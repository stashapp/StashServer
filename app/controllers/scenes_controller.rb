class ScenesController < ApplicationController
  before_action :set_scene, only: [:stream, :screenshot, :preview, :webp, :vtt, :chapter_vtt, :playlist]

  def stream
    send_file @scene.stream_file_path, disposition: 'inline'
  end

  def screenshot
    path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.jpg")
    thumb_path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.thumb.jpg")

    expires_in 1.week

    if params[:seconds]
      data = @scene.screenshot(seconds: params[:seconds], width: params[:width])
      send_data data, filename: 'screenshot.jpg', disposition: 'inline'
    elsif File.exist?(thumb_path) && params[:width] && params[:width].to_i < 400
      response.headers['Content-Length'] = File.size(thumb_path).to_s
      send_file thumb_path, disposition: 'inline'
    else
      response.headers['Content-Length'] = File.size(path).to_s
      send_file path, disposition: 'inline'
    end
  end

  def preview
    path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.mp4")
    if File.exist?(path)
      send_file path, disposition: 'inline'
    else
      # TODO: custom exception
      render json: {}, status: :not_found
    end
  end

  def webp
    path = File.join(StashMetadata::STASH_SCREENSHOTS_DIRECTORY, "#{@scene.checksum}.webp")
    if File.exist?(path)
      send_file path, disposition: 'inline'
    else
      # # TODO: custom exception
      # render json: {}, status: :not_found
      screenshot
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

end
