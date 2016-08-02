class SBScraper < SVScraper
  def get_base_url
    @url.match(/forums.spacebattles.com\/threads\/.+\.\d+/)
  end

  def get_chapter_urls
    @page.css(".threadmarkItem a").map do |t|
       "https://forums.spacebattles.com/#{t.attr('href')}".sub(/#post-\d+/, '')
    end
  end
end
