class Target < ApplicationRecord
  has_many :requests

  after_create :touch

  def touch
    self.update!(last_access: Time.now)
  end

  def scraper_class
    scraper.constantize
  end

end
