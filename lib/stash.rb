require 'fileutils'
require 'zip'
require 'naturally'

module Stash
  STASH_DIRECTORY             = File.expand_path(ENV['stash_directory'])
  STASH_METADATA_DIRECTORY    = File.expand_path(ENV['stash_metadata_directory'])
  STASH_CACHE_DIRECTORY       = File.expand_path(ENV['stash_cache_directory'])
  STASH_DOWNLOADS_DIRECTORY   = File.expand_path(ENV['stash_downloads_directory'])
  STASH_PERFORMERS_DIRECTORY  = File.join(STASH_METADATA_DIRECTORY, 'performers')
  STASH_SCENES_DIRECTORY      = File.join(STASH_METADATA_DIRECTORY, 'scenes')
  STASH_GALLERIES_DIRECTORY   = File.join(STASH_METADATA_DIRECTORY, 'galleries')
  STASH_STUDIOS_DIRECTORY     = File.join(STASH_METADATA_DIRECTORY, 'studios')
  STASH_SCREENSHOTS_DIRECTORY = File.join(STASH_METADATA_DIRECTORY, 'screenshots')
  STASH_VTT_DIRECTORY         = File.join(STASH_METADATA_DIRECTORY, 'vtt')
  STASH_MARKERS_DIRECTORY     = File.join(STASH_METADATA_DIRECTORY, 'markers')
  STASH_TRANSCODE_DIRECTORY   = File.join(STASH_METADATA_DIRECTORY, 'transcodes')
  STASH_MAPPINGS_FILE         = File.join(STASH_METADATA_DIRECTORY, 'mappings.json')
  STASH_SCRAPED_FILE          = File.join(STASH_METADATA_DIRECTORY, 'scraped.json')

  VALID_HTML5_CODECS          = ['h264', 'h265', 'vp8', 'vp9']

  class StashLoggerFormatter < Logger::Formatter
    Format = "%s, [%s#%d] %5s -- %s: %s"

    def call(severity, time, progname, msg)
      m = msg2str(msg)
      m << "\n" unless m[-1] == "\r"
      Format % [severity[0..0], format_datetime(time), $$, severity, progname, m.rjust(80)]
    end
  end

  def self.logger
    return @logger if @logger
    logger = Logger.new(STDOUT)
    logger.formatter = StashLoggerFormatter.new
    logger.level = Logger::INFO
    @logger = logger
  end
end
