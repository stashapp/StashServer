require 'streamio-ffmpeg'
require 'fastimage'

module VTTGenerator

  class Movie
    attr_reader   :info, :path, :number_of_frames, :nth_frame
    attr_accessor :thumb_width, :sprite_filename, :vtt_filename, :output_directory, :rows, :cols

    def initialize(path=nil, options={})
      raise Errno::ENOENT, "The file '#{path}' does not exist" unless File.exists?(path)

      @info = FFMPEG::Movie.new(path)
      @path = path
      @thumb_width = options[:thumb_width] ||= 160
      @sprite_filename = options[:sprite_filename] ||= "#{File.basename(@path, File.extname(@path))}_sprite.jpg"
      @vtt_filename = options[:vtt_filename] ||= "#{File.basename(@path, File.extname(@path))}_thumb.vtt"
      @output_directory = options[:output_directory] ||= "output/"
      @rows = 9
      @cols = 9

      video_streams = @info.metadata[:streams].select { |stream| stream.key?(:codec_type) and stream[:codec_type] === 'video' }
      video_stream = video_streams.first
      if video_stream.nil?
        raise Errno::EINVAL, "No valid video stream for file '#{path}'"
      end

      @number_of_frames = video_stream[:nb_frames].to_i
      if @number_of_frames == 0
        @number_of_frames = `ffmpeg -nostats -i #{@path} -vcodec copy -f rawvideo -y /dev/null 2>&1 | grep frame | awk '{split($0,a,"fps")}END{print a[1]}' | sed 's/.*= *//'`.to_i
      end
      @nth_frame = @number_of_frames / (@rows * @cols)
    end

    def generate
      generate_thumbs
      generate_vtt
    end

    private

    def generate_thumbs
      cmd = "ffmpeg -v quiet -threads 3 -i '#{@path}' -y -frames 1 -q:v 2 -vf 'select=not(mod(n\\,#{@nth_frame})),scale=#{@thumb_width}:-1,tile=#{@cols}x#{@rows}' '#{File.join(@output_directory, @sprite_filename)}'"
      VTTGenerator.logger.info("Generating thumbnail for #{@path}")
      system(cmd)
    end

    def generate_vtt
      size = FastImage.size(File.join(@output_directory, @sprite_filename))
      width = size[0] / @cols
      height = size[1] / @rows

      step_size = @nth_frame / @info.frame_rate

      vtt = ["WEBVTT",""]
      time = 0
      count = @rows * @cols
      count.times do |i|
        x = i % @rows * width
        y = i / @rows * height
        vtt.push("#{get_vtt_time(i*step_size)} --> #{get_vtt_time((i+1)*step_size)}")
        vtt.push("#{@sprite_filename}#xywh=#{x},#{y},#{width},#{height}")
        vtt.push("")
      end

      VTTGenerator.logger.info("Generating vtt for #{@path}")

      path = File.join(@output_directory, @vtt_filename)
      File.open(path, 'w+') do |f|
        f.write(vtt.join("\n"))
      end
    end

    def get_vtt_time(time)
      Time.at(time).gmtime.strftime('%H:%M:%S')
    end

  end
end
