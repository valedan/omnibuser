require 'rails_helper'

describe MOBIBuilder do
  before :all do
    @story = create(:story)
    @doc = Document.new(story_id: @story.id, filename: @story.title,
    extension: 'mobi')
    @doc.sanitize_filename
    3.times {create(:chapter, story_id: @story.id)}
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")
    @builder = MOBIBuilder.new(doc: @doc)
    @builder.build
  end

  after :all do
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")

    File.delete("/tmp/#{@doc.filename}.epub") if File.exist?("/tmp/#{@doc.filename}.epub")
    
    File.delete("/tmp/#{@doc.filename}.mobi") if File.exist?("/tmp/#{@doc.filename}.mobi")
  end

  describe '#build' do
    it "builds an epub of the doc" do
      expect(File.exist?("/tmp/#{@doc.filename}.epub")).to be true
    end
    it "converts to mobi" do
      expect(File.exist?("/tmp/#{@doc.filename}.mobi")).to be true
    end
  end
end
