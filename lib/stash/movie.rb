require 'streamio-ffmpeg'
require 'fastimage'

module Stash::Movie
  def self.screenshot(path:, seconds: nil, width: nil)
    movie = FFMPEG::Movie.new(path)

    unless width
      width = movie.width
    end
    unless seconds && seconds.to_i < movie.duration.to_i
      seconds = movie.duration * 0.2
    end

    escaped = Shellwords.escape(path)
    return `ffmpeg -v quiet -ss #{seconds} -i #{escaped} -vframes 1 -q:v 2 -vf scale='#{width}:-1' -f image2pipe pipe:1`
  end
end
