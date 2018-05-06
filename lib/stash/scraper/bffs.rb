class Stash::Scraper::Bffs < Stash::Scraper::SeleniumScraper
  def authenticated?
    return !@driver.title.include?('Login')
  end

  def auth_url
    return 'http://members.bffs.com/'
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      byebug #TODO
    end
  end

  def current_page_url
    return "http://members.bffs.com/sort/most-recent?page=#{@page}"
  end

  def page_count
    page_count = 1
    elements = @driver.find_element(class: 'pagination').find_elements(tag_name: 'a')
    elements.each { |e|
      num = e.text.to_i
      page_count = num if num > page_count
    }
    return page_count
  end

  def scrape
    authenticate

    loop {
      go_to_current_page
      max_page = page_count

      elements = @driver.find_elements(xpath: ".//a[contains(@href, 'members.bffs.com/trailer/')]")
      items = elements.map { |e|
        {
          url: e.attribute(:href)
        }
      }

      items.each { |item|
        try {
          @driver.get(item[:url])

          item[:url] = @driver.current_url
          item[:title] = @driver.find_element(xpath: ".//div[@class='contents2 main-text']").text.strip
          date = @driver.find_element(xpath: ".//span[contains(text(), 'DATE PUBLISHED')]").text.strip.gsub('DATE PUBLISHED: ', '')
          item[:date] = Date::strptime(date, '%m/%d/%Y').strftime('%F')
          item[:rating] = @driver.find_element(xpath: ".//span[@class='thumbs-percentage']").text.strip
          item[:description] = @driver.find_element(class: 'story-cointainer').text.strip.gsub("\nRead more", '')

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
      break if @page > max_page
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
      item[:video_url] = @driver.find_element(xpath: ".//a[contains(@href, '1080hd')]").attribute(:href)
      item[:gallery_url] = @driver.find_element(xpath: ".//a[contains(@href, 'pictures_hd')]").attribute(:href)
      item[:video_filename] = filename_from_url(item[:video_url])
      item[:gallery_filename] = filename_from_url(item[:gallery_url])
      return item
    end
end
