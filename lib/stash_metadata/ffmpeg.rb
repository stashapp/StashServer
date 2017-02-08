module StashMetadata
  module FFMPEG
    def self.screenshot path:, seconds: nil, width: nil
      movie = metadata(path: path)

      unless width
        width = movie.width
      end
      unless seconds
        seconds = movie.duration * 0.2
      end

      escaped = Shellwords.escape(path)
      return `ffmpeg -v quiet -ss #{seconds} -i #{escaped} -vframes 1 -q:v 2 -vf scale='#{width}:-1' -f image2pipe pipe:1`
    end

    def self.metadata path:
      ::FFMPEG::Movie.new(path)
    end
  end
end
