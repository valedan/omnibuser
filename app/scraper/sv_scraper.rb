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
    chapter.at_css(".messageContent .messageText").to_s
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
