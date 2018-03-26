class Stash::Scraper::Fakehub < Stash::Scraper::SeleniumScraper
  def authenticated?
    return !@driver.title.include?('Login')
  end

  def auth_url
    return 'https://ma.fakehub.com'
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      # TODO
      puts 'Login and then push enter'
      STDIN.gets
    end
  end

  def current_page_url
    if @studio.name == 'Fake Taxi'
      return "https://ma.fakehub.com/collection/5/fake-taxi/releases/#{@page}/"
    elsif @studio.name == 'Public Agent'
      return "https://ma.fakehub.com/collection/6/public-agent/releases/#{@page}/"
    else
      byebug
    end
  end

  def page_count
    @page_count
  end

  def scrape
    authenticate

    loop {
      go_to_current_page
      @page_count = @driver.find_element(xpath: "//a[contains(text(), 'Last')]").attribute(:href).split('/').last.to_i

      elements = @driver.find_elements(class: 'scene')
      items = elements.map { |e|
        link_element = e.find_element(xpath: ".//a[starts-with(@href, '/watch')]")
        {
          title: link_element.attribute(:title),
          date: Date.parse(e.find_element(tag_name: 'time').text.strip),
          url: link_element.attribute(:href)
        }
      }

      items.each { |item|
        try {
          @driver.get(item[:url])

          close_modal
          @driver.find_element(id: 'show-scene-info').click

          begin
            item[:description] = @driver.find_element(class: "about-scene-desc").text.strip
          rescue => e
            @manager.debug("no description for #{item[:url]}")
          end
          begin
            item[:rating] = "Likes: #{@driver.find_element(id: 'like-amount').text}, Dislikes: #{@driver.find_element(id: 'dislike-amount').text}"
          rescue => e
            @manager.info("no rating for #{item[:url]}")
          end
          begin
            item[:models] = @driver.find_element(class: 'related-model').find_elements(xpath: ".//a[contains(@href, '/model/')]").pluck(:text).join(', ')
          rescue => e
            @manager.info("no models for #{item[:url]}")
          end
          begin
            item[:tags] = @driver.find_element(class: "about-scene-cat").find_elements(tag_name: 'a').pluck(:text).join(', ')
          rescue => e
            @manager.info("no tags for #{item[:url]}")
          end

          item[:studio] = @studio

          scraped_item = ScrapedItem.find_by(date: item[:date], studio_id: @studio.id)
          item.merge!(file_info(scraped_item))
          if scraped_item
            scraped_item.update(item)
          else
            ScrapedItem.create(item)
          end
        }
      }

      @page += 1
      break if @page > page_count
    }
  end

  def download
    authenticate
    scraped_items.each { |item|
      next unless item.scene.nil?
      @driver.get(item.url)
      item.update(file_info(item))
      download_scene(item)
    }
  end

  private

    def file_info(scraped_item)
      item = {}
      item[:video_url] = @driver.find_elements(xpath: "//a[starts-with(@href, '/download')]").first.attribute(:href)

      if scraped_item
        item[:video_filename] = scraped_item.video_filename
      else
        item[:video_filename] = curl_filename(url: item[:video_url])

        if item[:video_filename].blank?
          byebug
          raise "Empty filename...  Slow down."
        end
      end

      return item
    end

    def close_modal
      @short_wait.until {
        button = @driver.find_elements(class: 'fancybox-close').find { |elm|
          elm.displayed?
        }
        button
      }
      button.click
    rescue
      return nil
    end

end
