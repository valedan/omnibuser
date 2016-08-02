class Scraper
  include ActiveModel::Model
  attr_accessor :url
  def new
  end

  def scrape
    @base_url = get_base_url
    return "Cannot find story at url provided." unless @base_url
    @agent = Mechanize.new
    if story_exists?
      update_story
    else
      get_story
    end
    @story.build
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
      live_chapters.shift(cached_chapters.length)
      get_chapters(live_chapters, cached_chapters.length)
    end
  end

  def get_chapters(chapter_urls, offset=0)
    chapter_urls.each_with_index do |chapter, index|
      sleep(4)
      @page = @agent.get(chapter) unless chapter == @page.uri
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + 1 + offset,
                     story_id: @story.id)
    end
  end

  def get_story
    @page = get_metadata_page
    @story = Story.create(url: @base_url,
                          title: get_story_title,
                          author: get_author)
    get_chapters(get_chapter_urls)
  end
end
