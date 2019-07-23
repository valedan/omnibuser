class ForumScraper < Scraper
  @queue = :scrape

  def get_story
    @target_data = @target.target_data
    @page = get_metadata_page
    title = get_story_title
    
    chapter_urls_with_dates = get_chapter_urls_with_dates(@page.css(@target_data['overlay_threadmark']))
    chapter_urls = chapter_urls_with_dates.map(&:first).map{|url| url.split('#')[0]}
    @page = queue_page("https://#{@base_url}")
    @story = Story.create(url: @base_url,
                          title: title,
                          author: get_author,
                          meta_data: get_metadata)
    get_cover_image
    if @request.strategy == 'all'
      @request.update(total_chapters: chapter_urls.length, current_chapters: 0)
      if reader_mode
        puts "reader mode true"
        first_post = @page.at_css(@target_data['post'])
        if first_post['class'].include?('hasThreadmark')
          @page = queue_page("https://#{@base_url}/reader")
          get_reader_chapters
        else
          create_chapter(first_post, 1, title: "Intro")
          @page = queue_page("https://#{@base_url}/reader")
          get_reader_chapters(2)
        end
      else
        puts "reader mode false"
        get_chapters(chapter_urls)
      end
    elsif @request.strategy == 'recent'
      chapter_urls, offset = recent_urls(chapter_urls_with_dates, @request.recent_number)
      @request.update(total_chapters: chapter_urls.count, current_chapters: 0)
      offset = 1 if offset < 1
      get_recent_chapters(chapter_urls, offset)
    end
  end

  def get_recent_chapters(chapter_urls, offset)
    chapter_urls.each do |url|
      chunks = url.split('#')
      post_id = chunks[1] if chunks[1]
      @page = queue_page(url)
      if post_id
        node = (@page.at_css("#js-#{post_id}") || @page.at_css("##{post_id}"))
      else
        node = threadmark_nodes.first
      end
      create_chapter(node, offset)
      offset += 1
      @request.increment!(:current_chapters)
    end
  end

  def recent_urls(urls, number)
    return urls.sort{|a, b| a[1] <=> b[1]}.last(number).map{|x| x[0]}, urls.length - @request.recent_number + 1
  end

  def get_chapter_urls_with_dates(threadmark_targets, urls=[])
    threadmark_targets.each do |t|
      if t.attributes['class'].value.include?('ThreadmarkFetcher') ||
         t.attributes['class'].value.include?('structItem--threadmark-filler')
        urls.concat(get_chapter_urls_with_dates(get_new_threadmarks(t).css(@target_data['threadmark_list_item']), urls))
      else
        urls << chapter_url_and_date(t)
      end
    end
    urls
  end

  def get_new_threadmarks(threadmark_fetcher)
    if target.domain.include?("sufficientvelocity")
      @agent.get("https://#{@target.domain}#{threadmark_fetcher.at_css('div').attributes['data-fetchurl'].value}")
    else
      @agent.post("https://#{@target.domain}/index.php?threads/threadmarks/load-range",
        'min' => threadmark_fetcher.attributes['data-range-min'].value,
        'max' => threadmark_fetcher.attributes['data-range-max'].value,
        'thread_id' => threadmark_fetcher.attributes['data-thread-id'].value
        )
      end
  end

  def chapter_url_and_date(threadmark)
    begin
      date = threadmark.at_css(@target_data['threadmark_date']).text.to_date
    rescue StandardError
      date = Time.now.to_date
    end
    
    [absolute_url(threadmark.at_css(@target_data['threadmark_url'])['href'], @page.uri), date]
  end

  def threadmark_nodes
    @page.css(@target_data['threadmark']).map{|node| story.domain == "sv" ? node.parent : node}
  end

  def get_reader_chapters(index=1)
    threadmark_nodes.each do |chapter|
      create_chapter(chapter, index)
      index += 1
      @request.increment!(:current_chapters)
    end
    if next_page
      @page = queue_page(next_page)
      get_reader_chapters(index)
    end
  end

  def next_page
    return false unless @page.at_css('.PageNav nav')
    @page.at_css('.PageNav nav').css('a').each do |a|
      return absolute_url(a['href'], @page.uri) if a.text == "Next >"
    end
    false
  end

  def get_publish_date(node)
    date = node&.at_css(@target_data['chapter_pub_date'])
    if date
      date.text&.to_date
    else
      nil
    end
  end

  def get_edit_date(node)
    date = node&.at_css(@target_data['chapter_edit_date'])
    if date
      date['data-datestring']&.to_date
    else
      nil
    end
  end

  def create_chapter(node, number, title: nil)
    Chapter.create(title: title ||= get_chapter_title(node),
                   content: get_chapter_content(node),
                   number: number,
                   story_id: @story.id,
                   publish_date: get_publish_date(node),
                   edit_date: get_edit_date(node))
  end

  def get_chapters(chapter_urls)
    chapter_urls.uniq!
    @index = 1
    chapter_urls.each do |url|
      @page = queue_page(url)
      threadmark_nodes.each do |chapter|
        create_chapter(chapter, @index)
        @index += 1
        @request.increment!(:current_chapters)
      end
    end
  end

  def reader_mode
    @page.at_css('.readerToggle')
  end

  def get_base_url
    @url.match(/(forums|forum)\.(sufficientvelocity|spacebattles|questionablequesting)\.com\/threads\/.+\.\d+/)
  end

  def get_metadata
    if @page.uri.to_s == "https://#{@base_url}/threadmarks"
      ""
    else
      pub_date = @page.at_css(@target_data['story_pub_date']).text
      {published: pub_date}.to_json
    end

  end

  def get_cover_image
    unless @page.uri.to_s == "https://#{@base_url}/threadmarks"
      return unless @page.at_css(@target_data['avatar'])
      parts = @page.at_css(@target_data['avatar'])['src'].split('/')
      return unless parts[-3]
      parts[-3] = 'l'
      url = "https://#{@page.uri.host}/#{parts.join('/')}"
      scrape_image(url, cover: true)
    end
  end

  def get_metadata_page
    begin
      queue_page("https://#{@base_url}/threadmarks")
    rescue StandardError => e
      if e.to_s.start_with?('404')
        raise ScraperError, "No threadmarks were found for this post. At this time only threads with threadmarks can be converted."
      else raise e
      end
    end
  end

  def get_story_title
    (@page.at_css(".titleBar h1") || @page.at_css(".p-title-value")).text.gsub(/( - Threadmarks|Threadmarks for: )/, '').strip
  end

  def get_author
    if @page.uri.to_s == "https://#{@base_url}/threadmarks"
      ""
    else
      @page.css(@target_data['post']).first.attr("data-author")
    end
  end

  def get_chapter_urls
    @page.css("#{@target_data['threadmark_list_item']} a").map do |t|
       "https://#{@base_url.to_s.split('threads/')[0]}#{t.attr('href')}".sub(/#post-\d+/, '')
    end
  end

  def get_chapter_title(chapter)
    chapter.at_css(@target_data['chapter_threadmark_text']).text.gsub(@target_data['chapter_threadmark_fluff'], '').strip
  end

  def get_chapter_content(chapter)
    content = chapter.at_css(@target_data['chapter_content'])
    content = absolutify_urls(content)
    extract_images(content).to_xml
  end
end
