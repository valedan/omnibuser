require 'rails_helper'

describe Scraper do

  describe '.perform' do
    it "creates a new scraper with correct url"
    it "updates request with story id"
    it "adds to resque queue"
  end

  describe '.create' do
    it "raises an error if no url was given"
    it "ensures url ends with a forward slash"
    it "instantiates a new Scraper of correct type with correct scraper queue"
  end

  describe '.determine_type' do
    it "raises an error if the website is not supported"
    it "returns the root url and the corresponding Scraper class if website is supported"
  end

  describe '#scrape' do
    it "raises an error if url does not point to a story"
    it "creates a new Mechanize agent with correct user agent"
    it "returns a Story object"
  end

  describe '#get_page' do
    it "gets the page at provided url"
    it "retries up to 3 times"
  end

  describe '#full_time' do
    it "returns the current time in hour:minute:second:nanosecond format"
  end

  describe '#scraper_log' do
    it "outputs a log line including current time, request id, and given message"
  end

  describe '#queue_page' do
    it "reloads the scraper queue"
    context "scraper queue has not been accessed for longer than the delay period" do
      it "updates the scraper queue's last access time to now"
      it "gets the page"
    end
    context "scraper queue has been accessed within the delay period" do
      it "sleeps until the end of the delay period plus a random interval up to 1 second"
      it "calls itself again"
    end
  end
end
