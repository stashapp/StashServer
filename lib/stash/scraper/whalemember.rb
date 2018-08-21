class Stash::Scraper::Whalemember < Stash::Scraper::SeleniumScraper
  def authenticated?
    begin
      !@driver.find_element(xpath: ".//a[contains(@href, 'login')]")
    rescue
      return true
    end
  end

  def auth_url
    if @studio.name == 'Exotic 4K'
      return "https://exotic4k.com"
    elsif @studio.name == 'Pure Mature'
      return "https://puremature.com"
    elsif @studio.name == 'Fantasy HD'
      return "https://fantasyhd.com"
    elsif @studio.name == 'POVD'
      return "https://povd.com"
    elsif @studio.name == 'Casting Couch X'
      return "https://castingcouch-x.com"
    elsif @studio.name == 'Lubed'
      return "https://lubed.com"
    elsif @studio.name == 'Tiny 4K'
      return "https://tiny4k.com"
    elsif @studio.name == 'BAEB'
      return "https://baeb.com"
    elsif @studio.name == 'Cum 4K'
      return "https://cum4k.com"
    else
      byebug
    end
  end

  def authenticate
    @driver.get(auth_url)
    unless authenticated?
      # @driver.find_element(xpath: ".//a[contains(@href, 'login')]").click
      byebug #TODO
    end
  end

  def current_page_url
    if @studio.name == 'Exotic 4K'
      return "https://exotic4k.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Pure Mature'
      return "https://puremature.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Fantasy HD'
      return "https://fantasyhd.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'POVD'
      return "https://povd.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Casting Couch X'
      return "https://castingcouch-x.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Lubed'
      return "https://lubed.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Tiny 4K'
      return "https://tiny4k.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'BAEB'
      return "https://baeb.com/scenes?page=#{@page}&sort=latest"
    elsif @studio.name == 'Cum 4K'
      return "https://cum4k.com/scenes?page=#{@page}&sort=latest"
    else
      byebug
    end
  end

  def page_count
    # TODO
    25
  end

  def scrape
    authenticate

    loop {
      go_to_current_page

      elements = @driver.find_elements(class: 'thumbnail')
      items = elements.map { |e|
        next if e.text.empty?

        rating = nil
        if @studio.name == 'BAEB'
          rating = e.find_element(tag_name: 'i').text.strip
        else
          rating = e.find_element(class: 'numbers').text.strip.sub("\n", ', ')
        end

        {
          url: e.find_element(xpath: ".//a[starts-with(@href, '/video/')]").attribute(:href),
          models: e.find_elements(xpath: ".//a[starts-with(@href, '/girls/')]").pluck(:text).join(', '),
          date: Date.parse(e.find_element(class: 'text-muted').text.strip),
          rating: rating
        }
      }
      items.compact! if items.include?(nil)

      items.each { |item|
        try {
          @driver.get(item[:url])

          item[:url] = @driver.current_url
          item[:title] = @driver.find_element(class: 'head').find_element(tag_name: 'h3').text.strip

          item.merge!(file_info)

          item[:studio] = @studio

          next if item[:video_filename].blank?
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
    authenticate
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

      video_links = @driver.find_element(class: 'video-options').find_elements(class: 'dropdown-menu').last.find_elements(tag_name: 'a')
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('_2160') }
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('_1080') } if vid_li_tag.nil?
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('_720_18') } if vid_li_tag.nil?
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('wmv_original') } if vid_li_tag.nil?
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('_750') } if vid_li_tag.nil?
      vid_li_tag = video_links.find { |el| el.attribute(:href).include?('mp4_480') } if vid_li_tag.nil?
      if vid_li_tag.nil?
        @manager.info("Video not found... skipping #{@driver.current_url}")
        return item
      end

      item[:video_url] = vid_li_tag.attribute(:href)
      item[:video_filename] = vid_li_tag.attribute(:download)

      begin
        zip_element = @driver.find_element(xpath: "//a[contains(text(), 'Download Picture Zip')]")
        item[:gallery_url] = zip_element.attribute(:href)
        item[:gallery_filename] = item[:video_filename].sub('mp4', 'zip')
        item[:gallery_filename] = item[:gallery_filename].sub('mpg', 'zip')
        item[:gallery_filename] = item[:gallery_filename].sub('wmv', 'zip')
      rescue => e
        @manager.debug("no gallery for #{@driver.current_url}")
      end

      return item
    end
end
