class TagsController < ApplicationController
  before_action :set_tag, only: [:show]

  def index
    @tags = Tag.search_for(params[:q])
               .pageable(params)
  end

  def show
  end

  def create
    @tag = Tag.create!(tag_params)
    render status: :created
  end

  private

    def set_tag
      @tag = Tag.find(params[:id])
    end

    def tag_params
      params.fetch(:tag).permit(:name)
    end
end
