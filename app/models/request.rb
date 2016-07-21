class Request < ApplicationRecord
  belongs_to :story, required: false
  validates :url, presence: true
  @valid_domains = {"fanfiction.net" => FFNScraper}

  def determine_type
    @valid_domains = {"fanfiction.net" => FFNScraper}
    uri = URI(url)
    puts uri
    domain_name = uri&.host&.sub(/^www\./, '')
    puts domain_name
    puts "TESTING"
    if @valid_domains.include?(domain_name)
      @valid_domains[domain_name]
    end
  end
end
