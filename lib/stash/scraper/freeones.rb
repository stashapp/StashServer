class Stash::Scraper::Freeones < Stash::Scraper::MechanizeScraper
  def get_performer(performer_name)
    page = @mechanize.get("https://www.freeones.com/search/?t=1&q=#{performer_name}&view=thumbs")
    link = page.links.find { |link| link.text.downcase == performer_name.downcase }
    return nil unless link

    page = link.click
    link = page.links.find { |link| link.text.include?('biography') }
    return nil unless link

    page = link.click
    params = page.search('.paramvalue')
    param_indexes = get_indexes(page.search('.paramname'))

    result = {}
    result[:url]           = page.uri.to_s
    result[:name]          = strip(params[param_indexes[:name]].text)
    result[:ethnicity]     = get_ethnicity(strip(params[param_indexes[:ethnicity]].text))
    result[:country]       = strip(params[param_indexes[:country]].text)
    result[:eye_color]     = strip(params[param_indexes[:eye_color]].text)
    result[:measurements]  = strip(params[param_indexes[:measurements]].text)
    result[:fake_tits]     = strip(params[param_indexes[:fake_tits]].text)
    result[:career_length] = strip(params[param_indexes[:career_length]].text.gsub(/\([\s\S]*/, ''))
    result[:tattoos]       = strip(params[param_indexes[:tattoos]].text)
    result[:piercings]     = strip(params[param_indexes[:piercings]].text)
    result[:aliases]       = strip(params[param_indexes[:aliases]].text)

    birth = strip(params[param_indexes[:birthdate]].text.gsub(/ \(\d* years old\)/, ''))
    if birth != 'Unknown' && !birth.blank?
      birthdate = Date.parse(birth)
      result[:birthdate] = birthdate.strftime('%F')
    end

    height = strip(params[param_indexes[:height]].text)
    match = /heightcm = "(.*)"\;/.match(height)
    if !match[1].nil?
      result[:height] = match[1]
    end

    twitter_element = page.search('.twitter a').first
    twitter_url = twitter_element[:href] unless twitter_element.nil?
    if !twitter_url.blank?
      result[:twitter] = URI(twitter_url).path.gsub('/', '')
    end

    instagram_element = page.search('.instagram a').first
    instagram_url = instagram_element.first[:href] unless instagram_element.nil?
    if !instagram_url.blank?
      result[:instagram] = URI(instagram_url).path.gsub('/', '')
    end

    return result
  end

  private

    def get_ethnicity(ethnicity)
      case ethnicity
      when 'Caucasian'
        return 'white'
      when 'Black'
        return 'black'
      when 'Latin'
        return 'hispanic'
      when 'Asian'
        return 'asian'
      else
        return nil
      end
    end

    def get_indexes(param_names)
      result = {}

      param_names.each_with_index { |param_name_element, i|
        param_name = strip(param_name_element.text)
        case param_name
        when 'Babe Name:'
          result[:name] = i
        when 'Ethnicity:'
          result[:ethnicity] = i
        when 'Country of Origin:'
          result[:country] = i
        when 'Date of Birth:'
          result[:birthdate] = i
        when 'Eye Color:'
          result[:eye_color] = i
        when 'Height:'
          result[:height] = i
        when 'Measurements:'
          result[:measurements] = i
        when 'Fake boobs:'
          result[:fake_tits] = i
        when 'Career Start And End'
          result[:career_length] = i
        when 'Tattoos:'
          result[:tattoos] = i
        when 'Piercings:'
          result[:piercings] = i
        when 'Aliases:'
          result[:aliases] = i
        else
        end
      }

      result
    end

    # https://stackoverflow.com/questions/20305966/why-does-strip-not-remove-the-leading-whitespace
    def strip(text)
      text.gsub(/\A\p{Space}*|\p{Space}*\z/, '')
    end
end
