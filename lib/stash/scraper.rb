require 'mechanize'

module Stash::Scraper
  class Base
  end

  class MechanizeScraper < Base
    def initialize
      @mechanize = Mechanize.new
    end
  end
end
