require 'streamio-ffmpeg'
require 'fastimage'

module WebmGenerator

  class Movie
    attr_reader   :info, :path, :number_of_frames, :nth_frame, :frame_rate
    attr_accessor :output_width, :output_filename, :output_directory, :chunk_count

    def initialize(path: nil, options: {})
      raise Errno::ENOENT, "The file '#{path}' does not exist" unless File.exists?(path)

      @info = FFMPEG::Movie.new(path)
      @path = path
      @output_width = options[:output_width] ||= 640
      @output_filename = options[:output_filename] ||= "#{File.basename(@path, File.extname(@path))}.mp4"
      @output_directory = options[:output_directory] ||= "output/"
      @chunk_count = 12

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
      @nth_frame = @number_of_frames / @chunk_count
    end

    def generate
      Dir.glob("#{@output_directory}/tmp/preview*.mp4") do |image|
        File.delete(image)
      end

      generate_concat_file
      generate_previews
    end

    private

    def generate_concat_file
      open("#{@output_directory}/tmp/files.txt", 'w') do |f|
        @chunk_count.times do |i|
          num = "%.3d" % i
          filename = "preview#{num}.mp4"
          f.puts("file '#{filename}'")
        end
      end
    end

    def generate_previews
      WebmGenerator.logger.info("Generating preview for #{@path}")

      step_size = @info.duration / @chunk_count
      @chunk_count.times do |i|
        time = i * step_size
        num = "%.3d" % i
        filename = "preview#{num}.mp4"
        cmd = "ffmpeg -v quiet -ss #{time} -t 0.75 -i \"#{@path}\" -c:v libx264 -profile:v high -level 4.2 -preset veryslow -crf 21 -threads 4 -vf scale=#{@output_width}:-2 -c:a aac -b:a 128k '#{File.join(@output_directory, 'tmp', filename)}'"
        system(cmd)
      end

      cmd = "ffmpeg -v quiet -f concat -i '#{@output_directory}/tmp/files.txt' -c copy #{File.join(@output_directory, @output_filename)}"
      system(cmd)
    end

  end
end
