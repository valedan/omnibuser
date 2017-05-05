require 'rails_helper'

describe PDFBuilder do
  before :all do
    @story = create(:story)
    @doc = Document.new(story_id: @story.id, filename: @story.title,
    extension: 'pdf')
    @doc.sanitize_filename
    30.times {create(:chapter, story_id: @story.id)}
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")
    @builder = PDFBuilder.new(doc: @doc)
    @builder.template_dir = Rails.root.join("app", "templates", 'html')
    @builder.domain = @story.domain
    @builder.create_directory_structure
  end

  after :all do
    FileUtils.rm_r("/tmp/#{@doc.filename}") if Dir.exist?("/tmp/#{@doc.filename}")

    File.delete("/tmp/#{@doc.filename}.pdf") if File.exist?("/tmp/#{@doc.filename}.pdf")
  end

  describe '#build' do
    after :each do
      allow_any_instance_of(PDFBuilder).to receive :convert_to_pdf
      allow_any_instance_of(PDFBuilder).to receive :combine_pdfs
      @builder.build
    end
    it "sets @domain" do
      allow_any_instance_of(PDFBuilder).to receive :convert_to_pdf
      allow_any_instance_of(PDFBuilder).to receive :combine_pdfs
      @builder.domain = nil
      @builder.build
      expect(@builder.domain).to eq @story.domain
    end
    it "creates directory structure" do
      expect_any_instance_of(PDFBuilder).to receive :create_directory_structure
    end
    it "adds styles" do
      expect_any_instance_of(PDFBuilder).to receive :add_styles
    end
    it "adds cover" do
      expect_any_instance_of(PDFBuilder).to receive :create_cover
    end
    it "adds images" do
      expect_any_instance_of(PDFBuilder).to receive :add_images
    end
    it "adds frontmatter" do
      expect_any_instance_of(PDFBuilder).to receive :create_frontmatter
    end
    it "adds content" do
      expect_any_instance_of(PDFBuilder).to receive :create_content
    end
    it "copies filler file" do
      expect(File.exist?("/tmp/#{@doc.filename}/filler.html")).to be true
    end
    it "converts to pdf" do
      expect_any_instance_of(PDFBuilder).to receive :convert_to_pdf
    end
    it "combines pdfs" do
      expect_any_instance_of(PDFBuilder).to receive :combine_pdfs
    end
  end
  describe '#create_frontmatter' do
    it "creates frontmatter file" do
      @builder.create_frontmatter
      expect(File.exist?("/tmp/#{@doc.filename}/frontmatter.html")).to be true
    end
  end
  describe '#create_content' do
    it "creates a html file for each 10 chapters" do
      @builder.create_content
      expect(File.exist?("/tmp/#{@doc.filename}/content_1.html")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/content_2.html")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/content_3.html")).to be true
      expect(File.exist?("/tmp/#{@doc.filename}/content_4.html")).to be false
    end
  end
  describe "pdf creation" do
    before :all do
      @builder.create_frontmatter
      @builder.create_content
      @builder.render_template('../pdf/filler.html.erb', 'filler.html')
      @builder.convert_to_pdf
    end
    describe '#convert_to_pdf' do
      it "creates a pdf for each file in @files" do
        expect(File.exist?("/tmp/#{@doc.filename}/content_1.pdf")).to be true
        expect(File.exist?("/tmp/#{@doc.filename}/content_2.pdf")).to be true
        expect(File.exist?("/tmp/#{@doc.filename}/content_3.pdf")).to be true
        expect(File.exist?("/tmp/#{@doc.filename}/frontmatter.pdf")).to be true
      end
    end
    describe '#combine_pdfs' do
      it "creates a new pdf at the doc path" do
        @builder.combine_pdfs
        expect(File.exist?("/tmp/#{@doc.filename}.pdf")).to be true
      end
    end
  end

end
