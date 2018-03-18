# NOTE: All commands need to be run in this format:
# rails 'scrape:scraper_name[:action, page_number, studio name]'
# For example: rails 'scrape:blacksonblondes[:download, 5, Blacks on Blondes]'
#
# Valid actions are: scrape, download, and populate

namespace :scrape do

  task :blacksonblondes, [:action, :page, :name] => [:environment] do |task, args|
    args.with_defaults(action: 'scrape', page: 1, name: 'Blacks on Blondes')

    studio = scrape_task_get_studio(args)
    scraper = Stash::Scraper::Dogfart.new(studio: studio, page: args[:page], action: args[:action])
    scrape_task_start_scrape(scraper, args)
  end

  task :pervmom, [:action, :page, :name] => [:environment] do |task, args|
    args.with_defaults(action: 'scrape', page: 1, name: 'PervMom')

    studio = scrape_task_get_studio(args)
    scraper = Stash::Scraper::Pervmom.new(studio: studio, page: args[:page], action: args[:action])
    scrape_task_start_scrape(scraper, args)
  end

  def scrape_task_start_scrape(scraper, args)
    Stash::Manager.instance.scrape(job_id: 'rake', scraper: scraper)
  end

  def scrape_task_get_studio(args)
    studio = Studio.find_by(name: args[:name])
    raise "Invalid studio!" if studio.nil?
    studio
  end
end
