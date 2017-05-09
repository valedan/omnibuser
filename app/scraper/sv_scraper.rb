class SVScraper < Scraper

  def get_story
    @page = get_metadata_page
    title = get_story_title
    chapter_urls = get_chapter_urls
    chapter_urls_with_dates = get_chapter_urls_with_dates
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
        first_post = @page.at_css('#messageList .message')
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
        node = @page.at_css("##{post_id}")
      else
        node = @page.at_css('.message.hasThreadmark')
      end
      create_chapter(node, offset)
      offset += 1
      @request.increment!(:current_chapters)
    end
  end

  def recent_urls(urls, number)
    return urls.sort{|a, b| a[1] <=> b[1]}.last(number).map{|x| x[0]}, urls.length - @request.recent_number + 1
  end

  def get_chapter_urls_with_dates
    urls = []
    @page.css(".overlayScroll.threadmarks li").each do |t|
       urls << [absolute_url(t.at_css('.PreviewTooltip')['href'], @page.uri), t.at_css('.DateTime').text.to_date]
    end
    urls
  end

  def get_reader_chapters(index=1)
    @page.css(".message.hasThreadmark").each do |chapter|
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
    date = node&.at_css('.messageInfo .messageMeta .datePermalink .DateTime')
    if date
      date.text&.to_date
    else
      nil
    end
  end

  def get_edit_date(node)
    date = node&.at_css('.messageInfo .editDate .DateTime')
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
      @page.css(".message.hasThreadmark").each do |chapter|
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
      pub_date = @page.at_css(".message .primaryContent .messageMeta .datePermalink").text
      {published: pub_date}.to_json
    end

  end

  def get_cover_image
    unless @page.uri.to_s == "https://#{@base_url}/threadmarks"
      parts = @page.at_css("#messageList .message .avatar img")['src'].split('/')
      return unless parts[-3]
      parts[-3] = 'l'
      url = "https://#{@page.uri.host}/#{parts.join('/')}"
      scrape_image(url, cover: true)
    end
  end

  def scrape_image(url, cover: false)
    begin
      puts "Retrieving image at #{url}"
      sleep(1)
      src = @agent.get(url)
    rescue Exception => e
      puts e
    end
    if src&.class == Mechanize::Image
      image = Image.create(story_id: @story.id,
                           extension: src['content-type'].split('/')[-1],
                           source_url: url,
                           cover: cover)
      if @story.domain == 'sv'
        background_color = '#282828'
      elsif @story.domain == 'sb'
        background_color = '#191F2D'
      elsif @story.domain == 'qq'
        background_color = '#EAEBEB'
      end
      unless url.include?('clear.png')
        begin
          src.save("#{image.path}.temp")
          image.compress(background_color)
        rescue Exception => e
          puts e
        end
      end
      src.save(image.path) unless File.exist?(image.path)
      image.upload
    end
    image&.name
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
    @page.at_css(".titleBar h1").text.split("Threadmarks for:")[1].strip
  end

  def get_author
    if @page.uri.to_s == "https://#{@base_url}/threadmarks"
      ""
    else
      @page.css("#messageList .message").first.attr("data-author")
    end
  end

  def get_chapter_urls
    @page.css(".threadmarkItem a").map do |t|
       "https://#{@base_url.to_s.split('threads/')[0]}#{t.attr('href')}".sub(/#post-\d+/, '')
    end
  end

  def get_chapter_title(chapter)
    chapter.at_css(".threadmarker .label").text.split("Threadmark:")[1].strip
  end

  def get_chapter_content(chapter)
    content = chapter.at_css(".messageContent .messageText")
    content = absolutify_urls(content)
    content = get_images(content)
    content = content.to_xml
    content
  end

  def get_images(content)
    content.search('img').each do |img|
      next if img['src'].blank?
      duplicate = @story.has_image(absolute_url(img['src'], @page.uri))
      if duplicate
        img['src'] = "#{duplicate.name}"
      else
        image = scrape_image(absolute_url(img['src'], @page.uri))
        img['src'] = "#{image}"
      end
    end
    content
  end

  def absolute_url(url, reference)
    url = url.split('#')
    unless url[0]&.start_with?('http') || url[0].blank?
      url[0] = "/#{url[0]}" unless url[0].start_with?('/')
      new_uri = URI::Generic.build({scheme: reference.scheme,
                                    host: reference.host,
                                    path: url[0].split('?')[0],
                                    query: url[0].split('?')[1],
                                    fragment: url[1]})
    end
    if new_uri
      new_uri.to_s
    else
      url.join('#')
    end
  end

  def absolutify_urls(content)
    content.search('a').each do |a|
      next if a['href'].blank?
      a['href'] = absolute_url(a['href'], @page.uri)
    end
    content
  end
end
