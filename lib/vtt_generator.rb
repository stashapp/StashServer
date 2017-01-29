require 'vtt_generator/movie'
require 'logger'

module VTTGenerator
  def self.logger=(log)
    @logger = log
  end

  def self.logger
    return @logger if @logger
    logger = Logger.new(STDOUT)
    logger.level = Logger::INFO
    @logger = logger
  end
end
