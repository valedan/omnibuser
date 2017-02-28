
class Scraper
  include ActiveModel::Model
  @queue = :scrape
  attr_accessor :url, :doc_id, :request, :squeue

  def self.perform(request_id)
    #temp
    begin
      request = Request.find(request_id)
      story = self.create(request.url, request).scrape
      request.update(story_id: story.id)
      doc_id = story.build(request.extension)
      request.update(doc_id: doc_id, complete: true, status: "Success")
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
                      "forums.spacebattles.com" => SVScraper,
                      "forum.questionablequesting.com" => SVScraper
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
    if story_exists?
      update_story
    else
      get_story
    end
    @story
  end

  def story_exists?
    @cached_story = Story.find_by("url LIKE ?", "%#{@base_url}%")
  end

  def update_story
    @story = @cached_story
    @page = get_metadata_page
    live_chapters = get_chapter_urls
    cached_chapters = @cached_story.chapters
    @request.update(total_chapters: live_chapters.length, current_chapters: cached_chapters.length)

    if cached_chapters.length == 0 || live_chapters.length == 1 || live_chapters.length < cached_chapters.length
      if @story.created_at < 5.minutes.ago
        @story.destroy
        get_story
      end
    elsif cached_chapters.length < live_chapters.length
      @story.update(meta_data: get_metadata)
      live_chapters.shift(cached_chapters.length)
      get_chapters(live_chapters, cached_chapters.length)
    end
  end

  def get_story
    @page = get_metadata_page
    @story = Story.create(url: @base_url,
                          title: get_story_title,
                          author: get_author,
                          meta_data: get_metadata)
    get_cover_image
    chapter_urls = get_chapter_urls
    @request.update(total_chapters: chapter_urls.length, current_chapters: 0)
    get_chapters(chapter_urls)
  end

  def get_page(url)
    scraper_log("Retrieving page #{url}")
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
