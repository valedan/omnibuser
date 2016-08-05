class QQScraper < SVScraper
  def get_base_url
    @url.match(/forum\.questionablequesting\.com\/threads\/.+\.\d+/)
  end

  def get_chapter_urls
    @page.css(".memberListItem a").map do |t|
       "https://forum.questionablequesting.com/#{t.attr('href')}"
    end
  end

  def get_chapters(chapter_urls, offset=0)
    chapter_urls.each_with_index do |url, index|
      @page = get_page(url)
      chapter = @page.at_css("[@id='#{@page.uri.fragment}']")
      @story.update(author: get_author) if @story.author.blank?
      Chapter.create(title: get_chapter_title(chapter),
                     content: get_chapter_content(chapter),
                     number: index + 1 + offset,
                     story_id: @story.id)
    end
  end
end
