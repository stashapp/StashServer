class Stash::Movie::Base
  def initialize(path:)
    @manager = Stash::Manager.instance
    @path = path
    @info = FFMPEG::Movie.new(@path)
    raise Errno::ENOENT, "The file '#{@path}' does not exist" unless File.exists?(@path)
    raise Errno::EINVAL, "The file '#{@path}' is not a valid video" unless @info.valid?
  end

  protected

    def configure
      video_streams = @info.metadata[:streams].select { |stream| stream.key?(:codec_type) && (stream[:codec_type] === 'video') }
      video_stream = video_streams.first
      if video_stream.nil?
        raise Errno::EINVAL, "No valid video stream for file '#{@path}'"
      end

      @frame_rate = @info.frame_rate || video_stream[:r_frame_rate].to_i
      @number_of_frames = video_stream[:nb_frames].to_i
      if @number_of_frames == 0
        @number_of_frames = `ffmpeg -nostats -i #{@path} -vcodec copy -f rawvideo -y /dev/null 2>&1 | grep frame | awk '{split($0,a,"fps")}END{print a[1]}' | sed 's/.*= *//'`.to_i
        if @number_of_frames == 0
          @number_of_frames = @frame_rate * @info.duration
        end
      end
      @nth_frame = @number_of_frames / @chunk_count
    end
end
