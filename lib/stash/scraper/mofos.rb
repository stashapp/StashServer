class Stash::Scraper::Mofos < Stash::Scraper::SeleniumScraper
  def authenticated?
    return !@driver.current_url.include?('login')
  end

  def auth_url
    return 'https://members2.mofos.com/'
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      byebug #TODO
    end
  end

  def current_page_url
    if @studio.name == 'Public Pickups'
      return "https://members2.mofos.com/scenes/public-pickups/all-models/all-categories/alltime/bydate/#{@page}/"
    elsif @studio.name == 'Stranded Teens'
      return "https://members2.mofos.com/scenes/stranded-teens/all-models/all-categories/alltime/bydate/#{@page}/"
    elsif @studio.name == 'Ebony Sex Tapes'
      return "https://members2.mofos.com/scenes/ebony-sex-tapes/all-models/all-categories/alltime/bydate/#{@page}/"
    else
      byebug
    end
  end

  def page_count
    # TODO
    26
  end

  def scrape
    authenticate

    loop {
      go_to_current_page

      elements = []
      @wait.until do
        elements = @driver.find_elements(class: 'widget-release-card-home')
        elements.count > 0
      end

      items = elements.map { |e|
        a = e.find_element(xpath: ".//a[contains(@href, '/scene/view/')]")
        {
          url: a.attribute(:href),
          title: a.attribute(:title).sub('Watch ', '').strip,
          date: Date.parse(e.find_element(class: 'date-added').text.strip)
        }
      }

      items.each { |item|
        try {
          @driver.get(item[:url])
          @driver.find_element(id: 'show-hide-details').click

          @short_wait.until do
            @driver.find_element(class: 'user-options-menu__download-frame-options').find_elements(tag_name: 'a').count > 0
          end

          item[:url] = @driver.current_url
          item[:description] = @driver.find_element(class: 'video-description').text.strip
          item[:models] = @driver.find_element(class: 'model-sitename-block').find_elements(class: 'model-name').pluck(:text).join(', ')
          item[:tags] = @driver.find_elements(class: 'tag-link').pluck(:text).delete_if { |tag| tag.include?('Download') }.join(', ')
          item[:rating] =  @driver.find_element(class: 'rating').text.strip
          item[:studio] = @studio

          scraped_item = ScrapedItem.find_by(date: item[:date], url: item[:url], studio_id: @studio.id)

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
      # item.update(file_info(item))
      download_scene(item) if item.scene.nil?
    }
  end

  private

    def file_info(scraped_item)
      item = {}

      video_urls = @driver.find_element(class: 'user-options-menu__download-frame-options').find_elements(tag_name: 'a')
      tag = video_urls.find { |el| el.attribute(:href).include?('_1080_') }
      tag = video_urls.find { |el| el.attribute(:href).include?('_720_') } if tag.nil?
      byebug if tag.nil?
      item[:video_url] = tag.attribute(:href)

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
