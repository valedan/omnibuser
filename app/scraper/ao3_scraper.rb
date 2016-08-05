class AO3Scraper < Scraper
  def get_base_url
    @url.match(/archiveofourown\.org\/works\/\d+/)
  end

  def get_story_title
    @page.at_css(".title.heading").text.strip
  end

  def get_author
    @page.at_css(".byline.heading a").text.strip
  end

  def get_metadata_page
    @agent.get("https://www.#{@base_url}?view_adult=true&view_full_work=true")
  end

  def get_chapter_urls
    @page.css("#chapters .chapter").map{|c| c.attribute("id")&.value}.delete_if{|x| x.nil?}
  end

  def get_front_matter
    frontmatter = @page.at_css(".preface.group .summary.module").to_s + "\n" +
    @page.at_css(".preface.group .notes.module").to_s

    Chapter.create(title: "",
                   content: frontmatter,
                   number: 0,
                   story_id: @story.id)
  end

  def get_single_chapter
    content = @page.at_css("#chapters .userstuff").to_s
    Chapter.create(title: "",
                   content: content,
                   number: 1,
                   story_id: @story.id)
  end

  def get_chapters(chapter_ids)
    get_front_matter
    if chapter_ids.empty?
      get_single_chapter
      return
    end
    chapter_ids.each do |chap_id|
      chapter = @page.at_css("##{chap_id}")
      index = chap_id.gsub(/chapter-/, '').to_i
      Chapter.create(title: get_chapter_title(chapter),
                     content: get_chapter_content(chapter),
                     number: index,
                     story_id: @story.id)
    end
  end

  def get_chapter_title(chapter)
    chapter.at_css(".title").text.strip
  end

  def update_story
    if @cached_story.created_at < 5.minutes.ago
      @cached_story.destroy
      get_story
    end
  end

  def get_chapter_content(chapter)
    chapter.at_css("#work").remove
    chapter.at_css("#notes").to_s + "\n" +
    chapter.at_css("#summary").to_s + "\n" +
    chapter.at_css(".userstuff.module").to_s
  end
end
