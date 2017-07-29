class TOCScraper < Scraper
  @queue = :scrape

  def get_base_url
    @target.target_data['toc_url']
  end

  def get_story
    @target_data = @target.target_data
    @page = queue_page(@target_data['toc_url'])
    chapter_urls = get_chapter_urls
    @story = Story.create(url: @target.domain,
                          title: @target_data['title'],
                          author: @target_data['author'])
    get_cover_image
    @offset = 0
    if @request.strategy == 'recent'
      @offset = chapter_urls.length - @request.recent_number
      chapter_urls = chapter_urls.last(@request.recent_number)
    end
    @request.update(total_chapters: chapter_urls.length, current_chapters: 0)
    get_chapters(chapter_urls)
  end

  def get_cover_image
    return unless @target_data['cover_image_url']
    scrape_image(@target_data['cover_image_url'], cover: true)
  end

  def get_chapter_urls
    filter_nodes(@page, @target_data['toc_filters'])
    @page.css(@target_data['chapter_urls']).map do |url|
      if url['href'].include?(@target.domain)
        if url['href'].start_with?('http')
          url['href']
        else
          "http://#{url['href']}"
        end
      else
        next
      end
    end.compact
  end

  def get_chapters(chapter_urls)
    chapter_urls.each_with_index do |chapter, index|
      @page = queue_page(chapter)
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + offset + 1,
                     story_id: @story.id)
      @request.increment!(:current_chapters)
    end
  end

  def get_chapter_content
    content = @page.at_css(@target_data['chapter_content'])
    filter_nodes(content, @target_data['content_filters'])
    extract_images(content).to_xml
  end

  def get_chapter_title
    @page.at_css(@target_data['chapter_title']).text
  end
end
