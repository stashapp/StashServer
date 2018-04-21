class Stash::Scraper::Portagloryhole < Stash::Scraper::SeleniumScraper
  def authenticated?
    begin
      @driver.browser.switch_to.alert
      false
    rescue
      true
    end
  end

  def auth_url
    return 'http://members.portagloryhole.com/memberst2'
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      byebug #TODO
    end
  end

  def current_page_url
    return "http://members.portagloryhole.com/memberst2/category.php?id=5&page=#{@page}&s=d"
  end

  def page_count
    8
  end

  def scrape
    authenticate

    loop {
      go_to_current_page

      elements = @driver.find_element(class: 'slides').find_elements(tag_name: 'li')
      items = elements.map { |e|
        e.location_once_scrolled_into_view
        {
          url: e.find_element(tag_name: 'a').attribute(:href),
          title: e.find_element(tag_name: 'h5').text.strip,
          rating: e.find_element(class: 'rating_box').attribute('data-rating').to_d.round(2).to_s,
          date: Date::strptime(e.find_element(class: 'fright_max48percent').text, '%m/%d/%Y').strftime('%F')
        }
      }

      items.each { |item|
        try {
          @driver.get(item[:url])

          item[:url] = @driver.current_url
          item[:models] = @driver.find_element(class: 'update_models').find_elements(tag_name: 'a').pluck(:text).join(', ')
          begin
            item[:tags] = @driver.find_element(class: 'video_categories').find_elements(tag_name: 'a').pluck(:text).join(', ')
          rescue => e
            @manager.debug("no tags for #{item[:url]}")
          end

          item.merge!(file_info)

          item[:studio] = @studio

          scraped_item = ScrapedItem.find_by(date: item[:date], video_filename: item[:video_filename])
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
    scraped_items.each { |item|
      next unless item.scene.nil? || item.gallery.nil?
      @driver.get(item.url)
      item.update(file_info)
      download_gallery(item) if item.gallery.nil?
      download_scene(item) if item.scene.nil?
    }
  end

  private

    def file_info
      item = {}

      link = @driver.find_elements(xpath: ".//a[contains(@href, 'download_button')]").find { |e| e.text.include?('1080p') }
      link.location_once_scrolled_into_view
      link.click

      item[:video_url] = @driver.find_element(id: 'download_url').attribute(:href)
      item[:video_filename] = filename_from_url(item[:video_url])

      gallery_url = @driver.current_url.sub('vids', 'highres')
      @driver.get(gallery_url)

      begin
        gallery_link = @driver.find_element(xpath: ".//a[contains(@href, '.zip')]")
        item[:gallery_url] = gallery_link.attribute(:href)
        item[:gallery_filename] = filename_from_url(item[:gallery_url])
      rescue => e
        @manager.debug("no gallery for #{@driver.current_url}")
      end

      return item
    end
end
