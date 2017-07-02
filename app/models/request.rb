class Request < ApplicationRecord
  belongs_to :story,  required: false
  belongs_to :target, required: false
  before_create :normalize_url
  after_create :set_target

  def scrape
    raise ScraperError, "Please enter a URL" if url.blank?
    begin
      Resque.enqueue(target.scraper_class, self.id)
    rescue Exception => e
      self.update!(complete: true, status: e)
      raise e
    end
  end

  def normalize_url
    self.url += '/' unless self.url.blank? || self.url.split('').last == '/'
  end


  def set_target
    target = Target.find{|t| url.include?(t.domain)}
    raise ScraperError, "The website you entered is not currently supported. See the About page for a list of supported sites, or the Contact page to request support for a new site" unless target
    self.update!(target_id: target.id)
  end

end
