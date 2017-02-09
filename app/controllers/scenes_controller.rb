class ScenesController < ApplicationController
  before_action :set_scene, only: [:show, :edit, :update, :stream, :screenshot, :vtt, :chapter_vtt]
  before_action :split_commas, only: [:update]

  def index
    whitelist = params.slice(:filter_studios, :filter_performers, :filter_tags, :filter_rating, :filter_missing)
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
    @scene.attributes = scene_params
    if params[:scene] && params[:scene][:gallery_id] && !params[:scene][:gallery_id].empty?
      @scene.gallery = Gallery.find(params[:scene][:gallery_id])
    end
    respond_to do |format|
      if @scene.save
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
    respond_to do |format|
      format.vtt { render inline: @scene.chapter_vtt }
    end
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
      params.fetch(:scene).permit(:title, :details, :url, :date, :rating, :studio_id, performer_ids: [], tag_ids: [])
    end

    def split_commas
      if params[:scene]
        params[:scene][:performer_ids] = params[:scene][:performer_ids].split(",") if params[:scene][:performer_ids]
        params[:scene][:tag_ids] = params[:scene][:tag_ids].split(",") if params[:scene][:tag_ids]
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
    end

    def sort_column
      Scene.column_names.include?(params[:sort]) ? params[:sort] : 'path'
    end

end
