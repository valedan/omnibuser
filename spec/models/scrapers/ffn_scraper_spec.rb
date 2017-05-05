require 'rails_helper'

describe FFNScraper do
  describe '#get_base_url' do
    it "matches either fictionpress.com or fanfiction.net"
    it "matches a story id in the url"
  end

  describe '#get_story' do
    it "gets the metadata page"
    it "creates a Story"
    it "gets cover image"
    context "request strategy is recent" do
      it "sets offset to the number of chapters skipped"
      it "collects the urls of the most recent X chapters"
    end
    context "request strategy is not recent" do
      it "sets offset to zero"
      it "collects the urls of all chapters"
    end
    it "updates the request with total chapters to get and initializes current chapters to zero"
    it "gets the chapters"
  end

  describe '#get_metadata' do
    it "gets the summary"
    it "gets the metadata"
    it "returns summary and metadata as a json hash"
  end

  describe '#get_story_title' do
    it "raises an error if it can't find the story title"
    it "returns the story title"
  end

  describe '#get_author' do
    it "returns the author name"
  end

  describe '#get_cover_image' do
    it "finds a cover image on the page"
    it "returns if it cannot find a cover image"
    it "gets the large version of the cover image"
    it "creates a new Image object with cover:true"
    it "uploads the image"
  end

  describe '#get_chapter_urls' do
    context "story only has one chapter" do
      it "returns the url of the current page"
    end
    context "story has multiple chapters" do
      it "returns the chapter urls"
    end
  end

  describe '#get_chapter_title' do
    it "defaults to a blank title"
    it "returns the chapter title"
  end

  describe '#get_chapters' do
    it "queues chapter urls"
    it "creates chapter objects"
    it "increments current_chapters on request"
  end

  describe '#get_chapter_content' do
    it "returns the chapter content"
  end

  describe '#get_metadata_page' do
    it "queues the page for chapter 1"
  end
end
