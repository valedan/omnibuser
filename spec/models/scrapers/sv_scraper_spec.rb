require 'rails_helper'

describe SVScraper do
  describe '#get_story' do
    it "creates a Story with title, author, metadata"
    it "gets cover image"
    context "request strategy is all" do
      context "reader mode is available" do
        it "creates a chapter from the first post if it is not threadmarked"
        it "queues the first reader mode page"
        it "gets all chapters via reader mode"
      end
      context "reader mode is not available" do
        it "gets all chapters"
      end
    end
    context "request strategy is recent" do
      it "updates request with total chapters"
      it "gets the most recent X chapters"
    end
  end
  describe '#get_recent_chapters' do
    it "navigates to the chapter url"
    it "finds the chapter"
    it "creates the chapter with correct offset"
    it "increments current_chapters on request"
  end
  describe '#recent_urls' do
    it "returns the most recent X urls from array given"
    it "returns correct offset"
  end
  describe '#get_chapter_urls_with_dates' do
    it "returns a 2D array of urls with dates"
  end
  describe '#get_reader_chapters' do
    it "creates a chapter from each threadmark on page"
    it "increments index with each chapter"
    it "increments current_chapters on request for each chapter"
    it "queues the next page and recurses if there is a next page"
  end
  describe '#next_page' do
    it "returns false if there is not a next page"
    it "returns the url to the next page if one exists"
  end
  describe '#get_publish_date' do
    it "returns the publish date if it exists"
  end
  describe '#get_edit_date' do
    it "returns the edit date if it exists"
  end
  describe '#create_chapter' do
    it "creates a Chapter"
    it "has a title"
    it "has content"
    it "has a number"
    it "has a story id"
    it "has a pub date"
    it "has an edit date if appropriate"
  end
  describe '#get_chapters' do
    it "navigates to each url"
    it "creates a chapter from every threadmark on each page"
    it "increments index for each chapter"
    it "increments current_chapters on request for each chapter"
  end
  describe '#reader_mode' do
    it "returns a node if reader mode is available"
    it "returns nil if reader mode is not available"
  end
  describe '#get_base_url' do
    it "matches on sb, sv, or qq"
    it "matches on the thread id"
  end
  describe '#get_metadata' do
    context "on threadmarks page" do
      it "returns an empty string"
    end
    context "not on threadmarks page" do
      it "returns the pub date as a json hash"
    end
  end
  describe '#get_cover_image' do
    it "does nothing if on threadmarks page"
    it "gets the avatar from the first post"
    it "gets the large version of the avatar"
    it "returns if avatar is a placeholder"
    it "scrapes the image"
  end
  describe '#scrape_image' do
    it "sleeps"
    it "downloads the image"
    it "creates an Image with correct parameters"
    it "chooses background color based on story domain"
    it "compresses the image"
    it "uploads the image"
    it "returns image name"
  end
  describe '#get_metadata_page' do
    it "queues the threadmarks page"
    it "raises an error on 404"
  end
  describe '#get_story_title' do
    it "returns the story title"
  end
  describe '#get_author' do
    context "on threadmarks page" do
      it "returns an empty string"
    end
    context "not on threadmarks page" do
      it "returns the author of the first post"
    end  end
  describe '#get_chapter_urls' do
    it "returns all threadmarks on page as array of urls"
    it "strips post id from urls"
  end
  describe '#get_chapter_title' do
    it "returns the chapter title"
  end
  describe '#get_chapter_content' do
    it "absoltifies all urls in the chapter"
    it "gets all images in the chapter"
    it "returns the chapter content"
  end
  describe '#get_images' do
    it "finds all img tags in content"
    it "skips images without a src"
    it "checks if story already has the image"
    context "image is duplicate" do
      it "changes src to name of image already on story"
    end
    context "image is not duplicate" do
      it "scrapes the image"
      it "changes src to name of image"
    end
    it "returns content"
  end
  describe '#absolute_url' do
    it "returns a url starting with http"
    it "returns a url with host corresponding to reference"
    it "includes all parts of given url"
  end
  describe '#absolutify_urls' do
      it "collects all links in content"
      it "skips link if href is blank"
      it "changes each href to absolute version"
      it "returns content"
  end
end
