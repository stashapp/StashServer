require 'streamio-ffmpeg'
require 'fastimage'

module VTTGenerator

  class Movie
    attr_reader   :info, :path, :number_of_frames, :nth_frame, :frame_rate
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

      @frame_rate = @info.frame_rate || video_stream[:r_frame_rate].to_i
      @number_of_frames = video_stream[:nb_frames].to_i
      if @number_of_frames == 0
        @number_of_frames = `ffmpeg -nostats -i #{@path} -vcodec copy -f rawvideo -y /dev/null 2>&1 | grep frame | awk '{split($0,a,"fps")}END{print a[1]}' | sed 's/.*= *//'`.to_i
        if @number_of_frames == 0
          @number_of_frames = @frame_rate * @info.duration
        end
      end
      @nth_frame = @number_of_frames / (@rows * @cols)
    end

    def generate
      Dir.glob("#{@output_directory}/tmp/thumbnail*.jpg") do |image|
        File.delete(image)
      end

      generate_thumbs
      generate_vtt
    end

    private

    def generate_thumbs
      VTTGenerator.logger.info("Generating thumbnail for #{@path}")

      count = @rows * @cols
      step_size = @info.duration / count
      count.times do |i|
        time = i * step_size
        num = "%.3d" % i
        filename = "thumbnail#{num}.jpg"
        cmd = "ffmpeg -v quiet -ss #{time} -y -i \"#{@path}\" -vframes 1 -q:v 1 -vf scale=#{@thumb_width}:-1 -f image2 '#{File.join(@output_directory, 'tmp', filename)}'"
        system(cmd)
      end

      images = []
      Dir.glob("#{@output_directory}/tmp/thumbnail*.jpg") do |image|
        images.push(image)
      end

      size = FastImage.size(images.first)
      cmd = "montage #{File.join(@output_directory, 'tmp', 'thumbnail*.jpg')} -tile #{@rows}x#{@cols} -geometry #{size[0]}x#{size[1]} #{File.join(@output_directory, @sprite_filename)}"
      system(cmd)
    end

    def generate_vtt
      size = FastImage.size(File.join(@output_directory, @sprite_filename))
      width = size[0] / @cols
      height = size[1] / @rows

      step_size = @nth_frame / @frame_rate

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
