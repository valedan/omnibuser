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
      #story =  update_story
      update_story
    else
      #story = get_story
      get_story
    end
    #story.build
  end

  def story_exists?
    @cached_story = Story.find_by("url LIKE ?", "%#{@base_url}%")
  end

  def get_story
    puts "NEW STORY"
    @page = get_metadata_page
    @story = Story.create(url: @base_url,
                          title: get_story_title,
                          author: get_author)
    chapters = get_chapter_urls
    p get_chapter_urls
    chapters.each_with_index do |chapter, index|
      puts "IN CHAPTERS LOOP"
      sleep(4)
      @page = @agent.get(chapter) unless chapter == @page.uri
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + 1,
                     story_id: @story.id)
    end
  end
end
