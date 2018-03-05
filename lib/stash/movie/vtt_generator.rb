class Stash::Movie::VTTGenerator < Stash::Movie::Base
  def initialize(path:, sprite_filename:, vtt_filename:, output_directory:)
    super(path: path)

    @thumb_width = 160
    @sprite_filename = sprite_filename
    @vtt_filename = vtt_filename
    @output_directory = output_directory
    @rows = 9
    @cols = 9
    @chunk_count = @rows * @cols

    configure
  end

  def generate
    Dir.glob("#{@output_directory}/tmp/thumbnail*.jpg") do |image|
      File.delete(image)
    end

    generate_sprite
    generate_vtt
  end

  private

    def generate_sprite
      @manager.info("Generating sprite for #{@path}")

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

      vtt = ["WEBVTT", ""]
      count = @rows * @cols
      count.times do |i|
        x = i % @rows * width
        y = i / @rows * height
        vtt.push("#{get_vtt_time(i * step_size)} --> #{get_vtt_time((i + 1) * step_size)}")
        vtt.push("#{@sprite_filename}#xywh=#{x},#{y},#{width},#{height}")
        vtt.push("")
      end

      @manager.info("Generating vtt for #{@path}")

      path = File.join(@output_directory, @vtt_filename)
      File.open(path, 'w+') do |f|
        f.write(vtt.join("\n"))
      end
    end

    def get_vtt_time(time)
      Time.at(time).gmtime.strftime('%H:%M:%S')
    end
end
