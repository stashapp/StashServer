class Stash::Scraper::Dogfart < Stash::Scraper::SeleniumScraper
  def authenticated?
    return !@driver.title.include?('Login')
  end

  def auth_url
    return 'https://www.dogfartnetwork.com/members/'
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      byebug #TODO
    end
  end

  def current_page_url
    if @studio.name == 'Gloryhole.com'
      return "http://#{@subdomain}.gloryhole.com/members/index.php?page=#{@page}&sort=date"
    elsif @studio.name == 'Interracial Pickups'
      return "http://#{@subdomain}.interracialpickups.com/members/index.php?page=#{@page}&sort=date"
    elsif @studio.name == 'Blacks on Blondes'
      return "http://#{@subdomain}.blacksonblondes.com/members/index.php?page=#{@page}&sort=date"
    else
      byebug
    end
  end

  def page_count
    #TODO
    # page_count = 1
    # elements = @driver.find_element(class: 'pagination').find_elements(tag_name: 'a')
    # elements.each { |e|
    #   num = e.text.to_i
    #   page_count = num if num > page_count
    # }
    # return page_count

    return 50
  end

  def scrape
    authenticate
    @subdomain = URI.parse(@driver.current_url).host.split('.').first

    loop {
      go_to_current_page

      elements = []
      @wait.until do
        elements = @driver.find_elements(xpath: "//div[@class='scene-container clearfix']")
        elements.count > 0
      end

      elements.each { |element|
        try {
          item = {}
          item[:url] = "#{@driver.current_url.split('index.php')[0]}?sid=#{element.find_element(class: 'add-favorite').attribute('data-scene')}"

          title_element = element.find_element(class: 'title')
          item[:title] = title_element.find_element(tag_name: 'b').text.strip

          title_items = element.text.split('Date:')[1].split('-')
          date_str = title_items[0].strip
          item[:date] = Date::strptime(date_str, '%m/%d/%Y').strftime('%F')

          item[:rating] = title_items[1].strip.sub('Rating: ', '')
          item[:description] = element.find_element(xpath: ".//p[@class='description hidden-phone']").text.strip

          item[:models] = element.find_elements(xpath: ".//a[contains(@href, 'model.php?model_id=')]").pluck(:text).join(', ')
          item[:tags] = element.find_elements(xpath: ".//a[contains(@href, 'search.php?type=categories')]").pluck(:text).join(', ')
          item[:studio] = @studio

          scraped_item = ScrapedItem.find_by(date: item[:date], title: item[:title], studio_id: @studio.id)
          item.merge!(file_info(element, scraped_item))

          if scraped_item
            scraped_item.update(item)
            scraped_item.populate_scene
          else
            ScrapedItem.create(item)
            @manager.debug("Used cURL to scrape the filename. Waiting 2.5 minutes... #{item[:video_url]}")
            sleep(60 * 2.5)
          end
        }
      }

      @page += 1
      @manager.debug("Waiting 1 minute before going to next page num #{@page}...")
      sleep(60) # Wait another minute before going to the next page
      break if @page > page_count
    }
  end

  def download
    authenticate
    @subdomain = URI.parse(@driver.current_url).host.split('.').first

    scraped_items.each { |item|
      next unless item.scene.nil?
      old_subdomain = URI.parse(item.url).host.split('.').first
      item.url = item.url.gsub(old_subdomain, @subdomain)

      @driver.get(item.url)

      elements = []
      @wait.until do
        elements = @driver.find_elements(xpath: "//div[@class='scene-container clearfix']")
        elements.count > 0
      end

      item.update(file_info(elements.first, item))
      download_gallery(item)
      download_scene(item)
    }
  end

  private

    def file_info(element, scraped_item)
      item = {}
      video_urls = element.find_elements(xpath: ".//a[contains(@href, './?action=download')]")
      url = video_urls.find { |el| el.attribute(:href).include?('1080p') && !el.attribute(:href).include?('stream=1') }
      url = video_urls.find { |el| el.attribute(:href).include?('file=big') && !el.attribute(:href).include?('stream=1') } if url.nil?
      item[:video_url] = url.attribute(:href)

      item[:gallery_url] = element.find_element(xpath: ".//a[contains(@href, 'members/zips/')]").attribute(:href)
      item[:gallery_filename] = filename_from_url(item[:gallery_url])

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
end
