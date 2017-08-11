require 'base64'

module ImageProcessor
  def process_image(params:, object:)
    if params[:image]
      in_content_type, encoding, string = params[:image].split(/[:;,]/)[1..3]

      @tempfile = Tempfile.new('upload-image')
      @tempfile.binmode
      @tempfile.write Base64.decode64(string)
      @tempfile.rewind

      # TODO: make portable
      # content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

      # extension = content_type.match(/gif|jpeg|png/).to_s
      # filename += ".#{extension}" if extension

      # ActionDispatch::Http::UploadedFile.new({
      #   tempfile: @tempfile,
      #   content_type: content_type,
      #   filename: filename
      # })

      object.checksum = Digest::MD5.file(@tempfile.path).hexdigest
      object.image = File.read(@tempfile.path)
    end
  ensure
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
end
