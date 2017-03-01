class FFNScraper < Scraper
  def get_base_url
    @url.match(/(fictionpress\.com|fanfiction\.net)\/s\/\d+\//)
  end

  def get_metadata
    summary = @page.at_css("#profile_top div.xcontrast_txt").text
    meta = @page.at_css("#profile_top span.xgray.xcontrast_txt").text
    {summary: summary, info: meta}.to_json
  end

  def get_story_title
    if @page.at_css("#profile_top .xcontrast_txt")
      return  @page.at_css("#profile_top .xcontrast_txt").text.strip
    else
      raise ScraperError, "Cannot find a story at url provided. Please recheck the url."
    end
  end

  def get_author
    @page.xpath("//a[starts-with(@href, '/u/')]").first.text.strip
  end

  def get_cover_image
    image = @page.search('.cimage')
    return unless image[1]
    parts = image[1]['src'].split('/')
    parts[-1] = '180/'
    url = parts.join('/')
    begin
      src = @agent.get(url)
    rescue Exception => e
      puts e
    end
    if src
      image = Image.create(story_id: @story.id,
                           extension: src['content-type'].split('/')[-1],
                           source_url: url,
                           cover: true)
      src.save(image.path)
      image.upload
    end
  end

  def get_chapter_urls
    unless @page.css("#chap_select").empty?
      @page.at_css("#chap_select").css("option").map do |option|
        "https://www.#{@base_url}#{option['value']}/"
      end
    else
      [@page.uri]
    end
  end

  def get_chapter_title
    options = @page.css('#chap_select option')
    title = ""
    options.each do |option|
      if option['selected']
        title = option.text.sub(/^\d+\./, '').strip
        break
      end
    end
    title
  end

  def get_chapters(chapter_urls)
    chapter_urls.each_with_index do |chapter, index|
      @page = queue_page(chapter) unless chapter == @page.uri
      Chapter.create(title: get_chapter_title,
                     content: get_chapter_content,
                     number: index + 1,
                     story_id: @story.id)
      @request.increment!(:current_chapters)
    end
  end

  def get_chapter_content
    @page.at_css("#storytext").to_s
  end

  def get_metadata_page
    queue_page("https://www.#{@base_url}1/")
  end


end
