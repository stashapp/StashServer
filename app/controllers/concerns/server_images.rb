require 'base64'

module ServerImages
  extend ActiveSupport::Concern

  included do
    before_action :set_server_images, only: [:new, :edit, :create, :update]
  end

  def set_server_images
    glob_path = File.join(StashMetadata::STASH_DIRECTORY, "*", "*.{jpg}")
    glob = Dir[glob_path]
    @server_images = []
    glob.each do |file|
      file = {data: Base64.encode64(open(file).to_a.join), path: file}
      @server_images.push(file)
    end
  end
end
