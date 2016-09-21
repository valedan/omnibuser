class ScraperQueue < ApplicationRecord
  #attr_accessor :domain, :last_access
  validates :domain, uniqueness: true

  def add(scraper)
    puts self.inspect
    puts "adding"
    self.queue.push(scraper.to_s)
    self.save
    puts self.inspect
  end

  def first?(scraper)
    puts self.inspect
    self.queue.first.to_s == scraper.to_s
  end

  def remove(scraper)
    puts self.inspect
    puts "removing"
    self.queue.shift if self.queue.first.to_s == scraper.to_s
    self.save
    puts self.inspect
  end

end
