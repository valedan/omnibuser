
class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue, :agent, :story, :target, :offset

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
    @agent.user_agent = "Omnibuser 1.2 www.omnibuser.com"
    get_story
    @story
  end

  def get_page(url)
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

  def queue_page(url)
    delay = 1.0
    @target.reload
    if Time.now - @target.last_access > delay
      @target.update!(last_access: Time.now)
      get_page(url)
    else
      sleep(delay - (Time.now - @target.last_access) + rand)
      queue_page(url)
    end
  end
end
