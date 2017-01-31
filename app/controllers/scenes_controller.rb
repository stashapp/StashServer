class ScenesController < ApplicationController
  before_action :set_scene, only: [:show, :edit, :update, :stream, :screenshot, :vtt, :chapter_vtt]

  def index
    whitelist = params.slice(:filter_studios, :filter_performers)
    @scenes = Scene
                .search_for(params[:q])
                .filter(whitelist)
                .reorder(sort_column + ' ' + sort_direction)
                .page(params[:page])
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

  def stream
    send_file @scene.path, disposition: 'inline'
  end

  def screenshot
    seconds = params[:seconds]

    # TODO Use this
    # screenshot = @scene.screenshot
    # if seconds
    #   # TODO add logic to return default if out of bounds
    #   screenshot = FFMPEGUtility.get_raw_screenshot @scene.absolute_path, seconds
    # end
    # send_data screenshot, type: 'image/jpg', disposition: 'inline'

    path = File.join(ENV['HOME'], "/.stash/screenshots/#{@scene.checksum}.jpg")
    send_file path, disposition: 'inline'
  end

  def vtt
    respond_to do |format|
      format.jpg {
        path = File.join(ENV['HOME'], "/.stash/vtt/#{@scene.checksum}_sprite.jpg")
        send_file path, disposition: 'inline'
      }
      format.vtt {
        path = File.join(ENV['HOME'], "/.stash/vtt/#{@scene.checksum}_thumbs.vtt")
        send_file path, disposition: 'inline'
      }
    end
  end

  def chapter_vtt
    respond_to do |format|
      format.vtt { render inline: @scene.chapter_vtt }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_scene
      params[:id].slice! '_thumbs.vtt'
      params[:id].slice! '_sprite.jpg'
      if Scene.find_by(checksum: params[:id])
        @scene = Scene.find_by(checksum: params[:id])
      else
        @scene = Scene.find(params[:id])
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scene_params
      params.fetch(:scene, {})
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'desc'
    end

    def sort_column
      Scene.column_names.include?(params[:sort]) ? params[:sort] : 'path'
    end

end
