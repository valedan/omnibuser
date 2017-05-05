require 'rails_helper'

describe HTMLBuilder do
  before :all do
    @story = create(:story)
    @doc = Document.new(story_id: @story.id, filename: @story.title,
    extension: 'html')
    @doc.sanitize_filename
    3.times {create(:chapter, story_id: @story.id)}
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")
    @builder = HTMLBuilder.new(doc: @doc)
    @builder.template_dir = Rails.root.join("app", "templates", 'html')
    @builder.domain = @story.domain
    @builder.create_directory_structure
  end

  after :all do
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")

    File.delete("/tmp/#{@doc.filename}.zip") if File.exist?("/tmp/#{@doc.filename}.zip")
  end

  describe '#build' do
    after :each do
      allow_any_instance_of(HTMLBuilder).to receive :zip_directory
      @builder.build
    end
    it "sets @domain" do
      allow_any_instance_of(HTMLBuilder).to receive :zip_directory
      @builder.domain = nil
      @builder.build
      expect(@builder.domain).to eq @story.domain
    end
    it "creates directory structure" do
      expect_any_instance_of(HTMLBuilder).to receive :create_directory_structure
    end
    it "adds style files" do
      expect_any_instance_of(HTMLBuilder).to receive :add_styles
    end
    it "adds cover image" do
      expect_any_instance_of(HTMLBuilder).to receive :create_cover
    end
    it "adds other images" do
      expect_any_instance_of(HTMLBuilder).to receive :add_images
    end
    it "adds story file" do
      expect_any_instance_of(HTMLBuilder).to receive :create_story
    end
    context "nozip is true" do
      it "returns the path to main story file" do
        expect(@builder.build(nozip: true)).to eq("/tmp/#{@doc.filename}/story.html")
      end
    end
    context "nozip is false" do
      it "zips the directory" do
        expect_any_instance_of(HTMLBuilder).to receive :zip_directory
      end
    end
  end
  describe '#create_directory_structure' do
    it "removes previous directory if it exists" do
      expect{@builder.create_directory_structure}.not_to raise_error
    end
    it "creates directory in /tmp named with doc filename" do
      expect(Dir.exist?("/tmp/#{@doc.filename}")).to be true
    end
    it "creates files subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/files")).to be true
    end
    it "creates styles subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/files/css")).to be true
    end
    it "creates images subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/files/images")).to be true
    end
  end
  describe '#add_styles' do
    before :each do
      @builder.domain = 'ffn'
      @builder.add_styles
    end
    it "adds the main css file to the folder" do
      expect(File.exist?("/tmp/#{@doc.filename}/files/css/main.css")).to be true
    end
    it "adds the domain specific css file to the folder" do
      expect(File.exist?("/tmp/#{@doc.filename}/files/css/#{@builder.domain}.css")).to be true
    end
  end
  describe "image handling", speed: 'slow' do
    before :all do
      @cover =    create(:image, story_id: @story.id, source_url: 'url1', cover: true)
      @image =    create(:png, story_id: @story.id, source_url: 'url2')
      FileUtils.cp(Rails.root.join("spec", "support", "images", "dice.png"),
      "#{@image.path}.temp")
      FileUtils.cp(Rails.root.join("spec", "support", "images", "lake.jpg"),
      "#{@cover.path}.temp")
      @cover.compress
      @image.compress
      @cover.upload
      @image.upload
      @builder.add_images
    end
    describe '#add_images' do
      it "downloads images to images subdir" do
        expect(File.exist?("/tmp/#{@doc.filename}/files/images/#{@image.name}")).to be true
      end
      it "only applies to images which are not a cover" do
        expect(File.exist?("/tmp/#{@doc.filename}/files/images/#{@cover.name}")).not_to be true
      end
      context "domain is sb or sv" do
        it "copies the smilies image to images subdir" do
          @builder.domain = 'sv'
          @builder.add_images
          expect(File.exist?("/tmp/#{@doc.filename}/files/images/xenforo-smilies-sprite.png")).to be true
          File.delete("/tmp/#{@doc.filename}/files/images/xenforo-smilies-sprite.png")
        end
      end
      context "domain is not sb or sv" do
        it "does not copy the smilies image to images subdir" do
          @builder.domain = 'ffn'
          @builder.add_images
          expect(File.exist?("/tmp/#{@doc.filename}/files/images/xenforo-smilies-sprite.png")).to be false
        end
      end
    end

    describe '#create_cover' do
      context "story has a cover image" do
        it "downloads cover image to images subdir" do
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/files/images/#{@cover.name}")).to be true
        end
      end
      context "story does not have a cover image" do
        before :all do
          @story.images.delete_all
        end
        it "copies the domain specific placeholder image to images subdir" do
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/files/images/#{@builder.domain}.png")).to be true
        end
        it "defaults to the omnibuser favicon if no domain is specified" do
          @builder.domain = nil
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/files/images/favicon.png")).to be true
        end
      end
    end
  end

  describe '#create_story' do
    it "creates the story file" do
      @builder.create_story
      expect(File.exist?("/tmp/#{@doc.filename}/story.html")).to be true
    end
  end
  describe '#zip_directory' do
    it "creates a new zip file with the doc filename and zip extension" do
      File.delete("/tmp/#{@doc.filename}.zip") if File.exist?("/tmp/#{@doc.filename}.zip")
      @builder.input = []
      @builder.zip_directory
      expect(File.exist?("/tmp/#{@doc.filename}.zip")).to be true
    end
  end
end
