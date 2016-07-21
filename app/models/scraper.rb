class Scraper
  include ActiveModel::Model
  attr_accessor :url
  def new
  end

  def scrape
    "You requested #{@url}"
  end
end
