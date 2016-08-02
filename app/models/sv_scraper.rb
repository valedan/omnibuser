class SVScraper < Scraper

  def get_base_url
    @url.match(/forums.sufficientvelocity.com\/threads\/.+\.\d+/)
  end

  def get_metadata_page
    #raise if no threadmarks
    @agent.get("https://#{@base_url}/threadmarks")
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
       "https://forums.sufficientvelocity.com/#{t.attr('href')}".sub(/#post-\d+/, '')
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
      sleep(4)
      @page = @agent.get(url)
      @story.update(author: get_author) if @story.author.blank?
      @page.css(".message.hasThreadmark").each do |chapter|
        next if chapter_exists?(chapter)
        Chapter.create(title: get_chapter_title(chapter),
                       content: get_chapter_content(chapter),
                       number: @index + offset,
                       story_id: @story.id)
        @index += 1
      end
    end
  end


end
