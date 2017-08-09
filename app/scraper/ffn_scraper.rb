class FFNScraper < Scraper
  @queue = :scrape

  def get_base_url
    @url.match(/(fictionpress\.com|fanfiction\.net)\/s\/\d+\//)
  end

  def get_story
    @target_data = @target.target_data
    @page = get_metadata_page
    @story = Story.create(url: @base_url,
                          title: get_story_title,
                          author: get_author,
                          meta_data: get_metadata)
    get_cover_image
    chapter_urls = get_chapter_urls
    if @request.strategy == 'recent'
      offset = chapter_urls.length - @request.recent_number
      chapter_urls = chapter_urls.last(@request.recent_number)
    end
    offset = 0 unless offset && offset > 0
    @request.update(total_chapters: chapter_urls.length, current_chapters: 0)
    get_chapters(chapter_urls, offset: offset)
  end

  def get_metadata
    summary = @page.at_css(@target_data['summary']).text
    meta = @page.at_css(@target_data['meta']).text
    {summary: summary, info: meta}.to_json
  end

  def get_story_title
    if @page.at_css(@target_data['title'])
      return  @page.at_css(@target_data['title']).text.strip
    else
      raise ScraperError, "Cannot find a story at url provided. Please recheck the url."
    end
  end

  def get_author
    @page.xpath(@target_data['author']).first.text.strip
  end

  def get_cover_image
    image = @page.search('.cimage')
    return unless image[1]
    parts = image[1]['src'].split('/')
    parts[-1] = '180/'
    url = parts.join('/')
    scrape_image(url, cover: true)
  end

  def get_chapter_urls
    unless @page.css(@target_data['chapter_urls']).empty?
      @page.at_css(@target_data['chapter_urls']).css("option").map do |option|
        "https://www.#{@base_url}#{option['value']}/"
      end
    else
      [@page.uri]
    end
  end

  def get_chapter_title
    options = @page.css(@target_data['chapter_titles'])
    title = ""
    options.each do |option|
      if option['selected']
        title = option.text.sub(/^\d+\./, '').strip
        break
      end
    end
    title
  end

  def get_chapters(chapter_urls, offset: 0)
    chapter_urls.each_with_index do |chapter, index|
      @page = queue_page(chapter) unless chapter == @page.uri
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + offset + 1,
                     story_id: @story.id)
      @request.increment!(:current_chapters)
    end
  end

  def get_chapter_content
    @page.at_css(@target_data['chapter_content']).to_s
  end

  def get_metadata_page
    queue_page("https://www.#{@base_url}1/")
  end


end
