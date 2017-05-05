require 'rails_helper'
require 'fileutils'

describe EPUBBuilder do
  before :all do
    @story = create(:story)
    @doc = Document.new(story_id: @story.id, filename: @story.title,
    extension: 'epub')
    @doc.sanitize_filename
    3.times {create(:chapter, story_id: @story.id)}
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")
    @builder = EPUBBuilder.new(doc: @doc)
    @builder.template_dir = Rails.root.join("app", "templates", 'epub')
    @builder.domain = @story.domain
    @builder.create_directory_structure
  end

  after :all do
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")

    File.delete("/tmp/#{@doc.filename}.epub") if File.exist?("/tmp/#{@doc.filename}.epub")
  end

  describe '#build' do

    after :each do
      allow_any_instance_of(EPUBBuilder).to receive :zip_directory
      @builder.build
    end
    it "sets @domain" do
      allow_any_instance_of(EPUBBuilder).to receive :zip_directory
      @builder.domain = nil
      @builder.build
      expect(@builder.domain).to eq @story.domain
    end
    it "creates directory structure" do
      expect_any_instance_of(EPUBBuilder).to receive :create_directory_structure
    end
    it "adds mimetype file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_mimetype
    end
    it "adds meta_inf file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_meta_inf_container
    end
    it "adds images" do
      expect_any_instance_of(EPUBBuilder).to receive :add_images
    end
    it "adds styles" do
      expect_any_instance_of(EPUBBuilder).to receive :add_styles
    end
    it "adds cover image" do
      expect_any_instance_of(EPUBBuilder).to receive :create_cover
    end
    it "adds frontmatter file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_frontmatter
    end
    it "adds content file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_content
    end
    it "adds toc file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_toc
    end
    it "adds toc_ncx file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_toc_ncx
    end
    it "adds package_opf file" do
      expect_any_instance_of(EPUBBuilder).to receive :create_package_opf
    end
    it "zips directory" do
      expect_any_instance_of(EPUBBuilder).to receive :zip_directory
    end
  end

  describe '#create_directory_structure' do
    it "removes previous directory if it exists" do
      expect{@builder.create_directory_structure}.not_to raise_error
    end
    it "creates directory in /tmp named with doc filename" do
      expect(Dir.exist?("/tmp/#{@doc.filename}")).to be true
    end
    it "creates META-INF subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/META-INF")).to be true
    end
    it "creates OPS subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/OPS")).to be true
    end
    it "creates OPS/book subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/OPS/book")).to be true
    end
    it "creates OPS/css subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/OPS/css")).to be true
    end
    it "creates OPS/images subdir" do
      expect(Dir.exist?("/tmp/#{@doc.filename}/OPS/images")).to be true
    end
  end

  describe '#create_mimetype' do
    it "creates mimetype file" do
      @builder.create_mimetype
      expect(File.exist?("/tmp/#{@doc.filename}/mimetype")).to be true
    end
  end
  describe '#create_meta_inf_container' do
    it "creates container file" do
      @builder.create_meta_inf_container
      expect(File.exist?("/tmp/#{@doc.filename}/META-INF/container.xml")).to be true
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
        expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/#{@image.name}")).to be true
      end
      it "only applies to images which are not a cover" do
        expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/#{@cover.name}")).not_to be true
      end
      context "domain is sb or sv" do
        it "copies the smilies image to images subdir" do
          @builder.domain = 'sv'
          @builder.add_images
          expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/xenforo-smilies-sprite.png")).to be true
          File.delete("/tmp/#{@doc.filename}/OPS/images/xenforo-smilies-sprite.png")
        end
      end
      context "domain is not sb or sv" do
        it "does not copy the smilies image to images subdir" do
          @builder.domain = 'ffn'
          @builder.add_images
          expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/xenforo-smilies-sprite.png")).to be false
        end
      end
    end

    describe '#create_cover' do
      context "story has a cover image" do
        it "downloads cover image to images subdir" do
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/#{@cover.name}")).to be true
        end
      end
      context "story does not have a cover image" do
        before :all do
          @story.images.delete_all
        end
        it "copies the domain specific placeholder image to images subdir" do
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/#{@builder.domain}.png")).to be true
        end
        it "defaults to the omnibuser favicon if no domain is specified" do
          @builder.domain = nil
          @builder.create_cover
          expect(File.exist?("/tmp/#{@doc.filename}/OPS/images/favicon.png")).to be true
        end
      end
      it "creates cover.xhtml file" do
        @builder.create_cover
        expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/cover.xhtml")).to be true
      end
    end
  end

  describe '#add_styles' do
    before :each do
      @builder.domain = 'ffn'
      @builder.add_styles
    end
    it "adds the main css file to the folder" do
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/css/main.css")).to be true
    end
    it "adds the domain specific css file to the folder" do
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/css/#{@builder.domain}.css")).to be true
    end
  end
  describe '#copy_from_template' do
    it "copies the file from the template dir to the actual dir" do
      FileUtils.touch("#{@builder.template_dir}/testfile")
      @builder.copy_from_template('testfile')
      expect(File.exist?("/tmp/#{@doc.filename}/testfile")).to be true
      File.delete("#{@builder.template_dir}/testfile")
      File.delete("/tmp/#{@doc.filename}/testfile")
    end
  end



  describe '#create_frontmatter' do
    it "creates the frontmatter file" do
      @builder.create_frontmatter
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/frontmatter.xhtml")).to be true
    end
  end
  describe '#create_content' do
    it "creates a file for each chapter" do
      @builder.create_content
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/Chapter_001.xhtml")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/Chapter_002.xhtml")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/Chapter_003.xhtml")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/Chapter_004.xhtml")).not_to be true
    end
  end
  describe '#create_toc' do
    it "creates the toc file" do
      @builder.create_toc
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/table-of-contents.xhtml")).to be true
    end
  end
  describe '#create_toc_ncx' do
    it "creates the toc ncx file" do
      @builder.create_toc_ncx
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/book/table-of-contents.ncx")).to be true
    end
  end
  describe '#create_package_opf' do
    it "creates package file" do
      @builder.create_package_opf
      expect(File.exist?("/tmp/#{@doc.filename}/OPS/package.opf")).to be true
    end
  end
  describe '#zip_directory' do
    it "creates a new zip file with the doc filename and epub extension" do
      File.delete("/tmp/#{@doc.filename}.epub") if File.exist?("/tmp/#{@doc.filename}.epub")
      @builder.input = []
      @builder.zip_directory
      expect(File.exist?("/tmp/#{@doc.filename}.epub")).to be true
    end
  end
end
