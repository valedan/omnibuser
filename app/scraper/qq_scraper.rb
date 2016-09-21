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
    @cached_chapters = @cached_story.chapters.all if offset > 0
    @index = 1
    until chapter_urls.empty? do
      puts chapter_urls
      url = chapter_urls.first
      @page = queue_page(url)
      @story.update(author: get_author) if @story.author.blank?
      @story.update(meta_data: get_metadata) if @story.meta_data.blank?
      @page.css(".message.hasThreadmark").each do |chapter|
        chapter_id = chapter.attr("id").split("-")[1]
        puts chapter_id
        chapter_urls.delete_if do |chapter_url|
          chapter_url.split("/").last == chapter_id
        end
        puts "after delete loop"
        puts chapter_urls
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
