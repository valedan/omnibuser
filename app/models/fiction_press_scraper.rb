class FictionPressScraper < FFNScraper
  def get_base_url
    @url.match(/fictionpress\.com\/s\/\d+\//)
  end
end
