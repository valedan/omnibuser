class SVScraper < Scraper
  def get_base_url
    @url.match(/forums\.(sufficientvelocity|spacebattles)\.com\/threads\/.+\.\d+/)
  end

  def get_metadata
    if @page.uri.to_s == "https://#{@base_url}/threadmarks"
      ""
    else
      pub_date = @page.at_css(".message.hasThreadmark .primaryContent .messageMeta .datePermalink").text
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
      src.save(image.path)
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

  def chapter_exists?(chapter)
    @cached_chapters && @cached_chapters.find_by(title: get_chapter_title(chapter))
  end

  def get_chapters(chapter_urls, offset=0)
    @cached_chapters = @cached_story.chapters.all if offset > 0
    chapter_urls.uniq!
    @index = 1
    chapter_urls.each do |url|
      @page = queue_page(url)
      get_cover_image if @story.cover_image.nil? && @index == 1
      @story.update(author: get_author) if @story.author.blank?
      @story.update(meta_data: get_metadata) if @story.meta_data.blank?
      @page.css(".message.hasThreadmark").each do |chapter|
        next if chapter_exists?(chapter)
        Chapter.create(title: get_chapter_title(chapter),
                       content: get_chapter_content(chapter),
                       number: @index + offset,
                       story_id: @story.id)
        @index += 1
        @request.increment!(:current_chapters)
      end

    end
  end


end
