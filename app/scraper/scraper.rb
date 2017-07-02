
class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue, :agent, :story, :target

  def self.perform(request_id)
    begin
      request = Request.find(request_id)
      story = self.new(url: request.url, request: request, target: request.target).scrape
      request.update!(story_id: story.id)
      Resque.enqueue(DelayedBuilder, request.id)
    rescue Exception => e
      request.update(complete: true, status: e)
      raise e
    end
  end

  def scrape
    @base_url = get_base_url
    raise ScraperError, "Cannot find a story at url provided. Please recheck the url." unless @base_url
    @agent = Mechanize.new
    @agent.user_agent = "Omnibuser 1.1 www.omnibuser.com"
    get_story
    @story
  end

  def get_page(url)
    scraper_log("Retrieving page #{url}")
    puts "Retrieving page #{url}"
    tries = 3
    begin
      @agent.get(url)
    rescue Exception => e
      if tries > 0
        tries -= 1
        retry
      else
        raise e
      end
    end
  end

  def full_time
    Time.now.strftime('%H:%M:%S::%N')
  end

  def scraper_log(string)
    Rails.logger.warn("#{full_time} - #{@request.id} - #{string}")
  end

  def queue_page(url)
    delay = 1.5
    @target.reload
    scraper_log("Just reloaded target - #{@target.inspect}")
    if Time.now - @target.last_access > delay
      @target.update!(last_access: Time.now)
      scraper_log("Updated queue - #{@target.inspect}")
      get_page(url)
    else
      sleep(delay - (Time.now - @target.last_access) + rand)
      queue_page(url)
    end
  end
end
