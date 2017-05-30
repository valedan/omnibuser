
class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue, :agent, :story

  def self.perform(request_id)
    begin
      request = Request.find(request_id)
      story = self.create(request.url, request).scrape
      request.update(story_id: story.id)
      Resque.enqueue(DelayedBuilder, request.id)
    rescue Exception => e
      request.update(complete: true, status: e)
      raise e
    end
  end

  def self.create(url, request)
    unless url.blank?
      @url = url
    else
      raise ScraperError, "Please enter a URL"
    end
    @url += "/" unless @url.split('').last == "/"
    @request = request
    root, scraper = determine_type
    scraper.new(url: @url, request: @request, squeue: ScraperQueue.find_by(domain: root))
  end

  def self.determine_type
    @valid_domains = {"fanfiction.net" => FFNScraper,
                      "fictionpress.com" => FFNScraper,
                      "forums.sufficientvelocity.com" => SVScraper,
                      "forums.spacebattles.com" => SBScraper,
                      "forum.questionablequesting.com" => QQScraper
                      }
    @valid_domains.each do |key, value|
      if @url.include?(key)
        return key, value
      end
    end
    raise ScraperError, "The website you entered is not currently supported. See the About page for a list of supported sites, or the Contact page to request support for a new site."
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
    @squeue.reload
    scraper_log("Just reloaded queue - #{@squeue.inspect}")
    if Time.now - @squeue.last_access > delay
      @squeue.update(last_access: Time.now)
      scraper_log("Updated queue - #{@squeue.inspect}")
      get_page(url)
    else
      sleep(delay - (Time.now - @squeue.last_access) + rand)
      queue_page(url)
    end
  end


end
