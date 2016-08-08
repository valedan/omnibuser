
class Scraper
  include ActiveModel::Model
  attr_accessor :url, :doc_id

  def self.create(url)
    @url = url
    determine_type.new(url: @url)
  end

  def self.determine_type
    @valid_domains = {"fanfiction.net" => FFNScraper,
                      "fictionpress.com" => FFNScraper,
                      "forums.sufficientvelocity.com" => SVScraper,
                      "forums.spacebattles.com" => SVScraper,
                      "forum.questionablequesting.com" => QQScraper
                      }
    @valid_domains.each_key do |domain|
      if @url.include?(domain)
        return @valid_domains[domain]
      end
    end
    raise ScraperError, "Site not supported"
  end

  def scrape
    @base_url = get_base_url
    raise ScraperError, "Cannot find story at url provided." unless @base_url
    @agent = Mechanize.new
    @agent.user_agent = "This is an experimental bot. If you have questions or concerns please email me: danieljmolloy1@gmail.com"
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
    get_chapters(get_chapter_urls)
  end

  def get_page(url)
    tries = 3
    begin
      sleep(1)
      @agent.get(url)
    rescue Exception => e
      if tries > 0
        tries -= 1
        retry
      else
        raise ScraperError, e.message
      end
    end
  end
end
