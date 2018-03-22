class Stash::Movie::PreviewGenerator < Stash::Movie::Base
  def initialize(path:, video_filename:, image_filename:, output_directory:)
    super(path: path)
    @width = 640
    @video_filename = video_filename
    @image_filename = image_filename
    @output_directory = output_directory
    @chunk_count = 12
    configure
  end

  def generate
    glob_path = File.join(temp_path, 'preview*.mp4')
    Dir.glob(glob_path) do |file|
      File.delete(file)
    end

    @manager.info("Generating preview for #{@path}")

    generate_concat_file
    generate_video
    generate_image
  end

  private

    def temp_path
      File.join(@output_directory, 'tmp')
    end

    def concat_file_path
      File.join(temp_path, 'files.txt')
    end

    def generate_concat_file
      open(concat_file_path, 'w') do |f|
        @chunk_count.times do |i|
          num = "%.3d" % i
          filename = "preview#{num}.mp4"
          f.puts("file '#{filename}'")
        end
      end
    end

    def generate_video
      video_output_path = File.join(@output_directory, @video_filename)
      return if File.exist?(video_output_path)

      step_size = @info.duration / @chunk_count
      @chunk_count.times do |i|
        time = i * step_size
        num = "%.3d" % i
        filename = "preview#{num}.mp4"
        chunk_output_path = File.join(temp_path, filename)
        cmd = "ffmpeg -v quiet -ss #{time} -t 0.75 -i \"#{@path}\" -y -c:v libx264 -profile:v high -level 4.2 -preset veryslow -crf 21 -threads 4 -vf scale=#{@width}:-2 -c:a aac -b:a 128k '#{chunk_output_path}'"
        system(cmd)
      end

      video_output_path = File.join(@output_directory, @video_filename)
      cmd = "ffmpeg -v quiet -f concat -i '#{concat_file_path}' -y -c copy \"#{video_output_path}\""
      if system(cmd)
        @manager.info("Created video preview #{video_output_path}")
      else
        @manager.error("Error running ffmpeg when creating video preview #{$?}")
      end
    end

    def generate_image
      image_output_path = File.join(@output_directory, @image_filename)
      tmp_path = File.join(temp_path, @image_filename)
      return if File.exist?(image_output_path)

      video_output_path = File.join(@output_directory, @video_filename)
      cmd = "ffmpeg -v quiet -i \"#{video_output_path}\" -y -c:v libwebp -lossless 1 -q:v 70 -compression_level 6 -preset default -loop 0 -threads 4 -vf scale=#{@width}:-2,fps=12 -an \"#{tmp_path}\""
      if system(cmd)
        FileUtils.mv(tmp_path, image_output_path)
        @manager.info("Created image preview #{image_output_path}")
      else
        @manager.error("Error running ffmpeg when creating image preview #{$?}")
      end
    end
end
