require 'mechanize'
require 'selenium-webdriver'

module Stash::Scraper
  class Base
  end

  class MechanizeScraper < Base
    def initialize
      @mechanize = Mechanize.new
      @mechanize.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  class SeleniumScraper < Base
    def initialize(studio:, page: 1, action: :scrape)
      @manager = Stash::Manager.instance

      case action
      when String
        @action = action.to_sym
      when Symbol
        @action = action
      else
        raise "Invalid action type"
      end

      raise "Invalid action.  Use scrape, download, or populate." unless [:scrape, :download, :populate].include?(@action)

      unless @action == :populate
        chrome_profile = File.join(Stash::STASH_METADATA_DIRECTORY, 'chrome')
        options = Selenium::WebDriver::Chrome::Options.new(args: ["user-data-dir=#{chrome_profile}"]) #'headless',
        @driver = Selenium::WebDriver.for(:chrome, options: options)
        @driver.manage.timeouts.implicit_wait = 5
        @wait = Selenium::WebDriver::Wait.new(:timeout => 60)
        @short_wait = Selenium::WebDriver::Wait.new(timeout: 5)
      end

      @studio = studio
      @page = page
    end

    def start
      case @action
      when :scrape
        scrape
      when :download
        download
      when :populate
        populate
      else
        raise "Invalid action"
      end
    end

    def authenticated?
      raise "Override authenticated?"
    end

    def auth_url
      raise "Override auth"
    end

    def authenticate
      raise "Override authenticate"
    end

    def current_page_url
      raise "Override current_page_url"
    end

    def page_count
      raise "Override page_count"
    end

    def scrape
      raise "Override scrape"
    end

    def download
      raise "Override download"
    end

    def populate
      scraped_items.each { |item|
        next if item.scene.nil?
        next unless item.scene.studio.nil?
        @manager.info("Populating #{item.title}")
        item.populate_scene
      }
    end

    def go_to_current_page
      @driver.get(current_page_url)
      @manager.info("Page #{@page}")
    end

    def filename_from_url(url)
      File.basename(URI.parse(url).path)
    end

    def scraped_items
      ScrapedItem.where(studio_id: @studio.id)
    end

    def try
      yield
    rescue Selenium::WebDriver::Error::TimeOutError
      retry
    rescue Net::ReadTimeout
      retry
    rescue ScriptError => e
      @manager.error("#{e.inspect} --> #{e.backtrace.first}")
      raise e
    rescue => e
      @manager.error("#{e.inspect} --> #{e.backtrace.first}")
      raise e
    end

    protected

      def download_gallery(scraped_item)
        return if scraped_item.gallery_filename.blank?

        path = File.join(Stash::STASH_DOWNLOADS_DIRECTORY, scraped_item.gallery_filename)
        if File.exist?(path)
          @manager.info("Already downloaded #{scraped_item.gallery_filename}.")
        elsif !scraped_item.gallery.nil?
          @manager.info("Gallery already exists #{scraped_item.gallery.path}.  Not downloading...")
        else
          @manager.info("Downloading #{scraped_item.gallery_filename}...")
          download_file(url: scraped_item.gallery_url, filename: scraped_item.gallery_filename)
        end
      end

      def download_scene(scraped_item)
        path = File.join(Stash::STASH_DOWNLOADS_DIRECTORY, scraped_item.video_filename)
        if File.exist?(path)
          @manager.info("Already downloaded #{scraped_item.video_filename}.")
        elsif !scraped_item.scene.nil?
          @manager.info("Scene already exists #{scraped_item.scene.path}.  Not downloading...")
        else
          @manager.info("Downloading #{scraped_item.video_filename}...")
          download_file(url: scraped_item.video_url, filename: scraped_item.video_filename)
        end
      end

    private

      def download_file(url:, threads: 3, filename: nil)
        Dir.chdir(Stash::STASH_DOWNLOADS_DIRECTORY) do
          output = filename.nil? ? " " : " -o '#{filename}' "
          cmd = "aria2c#{output}'#{curl_url(url: url)}' -R -x 16 -s #{threads} --file-allocation=none --summary-interval=0 #{aria_headers}"
          system(cmd)
        end
      end

      def generate_cookie_header
        result = ""
        @driver.manage.all_cookies.each { |cookie|
          result << "#{cookie[:name]}=#{cookie[:value]}; "
        }
        return result.strip
      end

      def curl_url(url:)
        `curl '#{url}' -sLI  #{curl_headers} -o /dev/null -w %{url_effective}`
      end

      def curl_filename(url:)
        headers = `curl '#{url}' -sIL #{curl_headers}`
        if headers.include?('302 Found')
          url = headers.split('Location: ')[1].split[0]
          return File.basename(URI.parse(url).path)
        else
          return `echo '#{headers}' | grep -o -E 'filename=.*$' | sed -e 's/filename=//'`.gsub(/['"]/, '').strip
        end
      end

      def curl_headers
        user_agent = @driver.execute_script("return navigator.userAgent")
        referrer = @driver.execute_script("return document.referrer")
        return "-H 'User-Agent: #{user_agent}' -H 'Referer: #{referrer}' -H 'Cookie: #{generate_cookie_header}' -H 'Connection: keep-alive'"
      end

      def aria_headers
        user_agent = @driver.execute_script("return navigator.userAgent")
        referrer = @driver.execute_script("return document.referrer")
        return "--header='User-Agent: #{user_agent}' --header='Referer: #{referrer}' --header='Cookie: #{generate_cookie_header}' --header='Connection: keep-alive'"
      end
  end
end
