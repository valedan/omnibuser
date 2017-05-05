require 'rails_helper'

describe Document do
  it { should belong_to(:story) }

  describe '#sanitize_filename' do
    before :each do
      allow_any_instance_of(Document).to receive(:add_chapter_numbers).and_return("cnums added")
      @doc = build(:document, filename: 'ad-hoc')
    end
    it "replaces non-alphanumeric characters with underscores" do
      expect(build_doc_with_name('ad-hoc').filename).to eq('ad_hoc')
    end
    it "does not have consecutive underscores" do
      expect(build_doc_with_name('ad--hoc').filename).to eq('ad_hoc')
    end
    it "does not have leading underscores" do
      expect(build_doc_with_name('-ad-hoc').filename).to eq('ad_hoc')
    end
    it "does not have trailing underscores" do
      expect(build_doc_with_name('ad-hoc-').filename).to eq('ad_hoc')
    end
    it "is shorter than 230 characters" do
      expect(build_doc_with_name('a'*300).filename.length).to be <= 230
    end
    it "adds chapter range if recent strategy was used" do
      @doc.story.request.update strategy: 'recent'
      expect(@doc.sanitize_filename).to eq 'cnums added'
    end
    it "does not add chapter range if recent strategy was not used" do
      @doc.story.request.update strategy: 'all'
      expect(@doc.sanitize_filename).not_to eq 'cnums added'
    end
  end

  describe '#add_chapter_numbers' do
    before :all do
      FactoryGirl.reload
      @story = create(:ffn_story)
      create(:chapter, story_id: @story.id)
    end
    it "only adds a single number if there is only one chapter" do
      doc = build(:document, story_id: @story.id, filename: 'single')
      doc.add_chapter_numbers
      expect(doc.filename).to eq('single_1')
    end
    it "adds first and last chapter numbers if more than one chapter" do
      create(:chapter, story_id: @story.id)
      create(:chapter, story_id: @story.id)
      doc = build(:document, story_id: @story.id, filename: 'multiple')
      doc.add_chapter_numbers
      expect(doc.filename).to eq('multiple_1-3')
    end
  end

  describe '#path' do
    it "returns doc's path" do
      doc = build(:document)
      expect(doc.path).to eq("/tmp/#{doc.filename}.#{doc.extension}")
    end
  end

  describe '#delete_file' do
    it "deletes the doc file if it exists" do
      doc = build(:document)
      FileUtils.touch(doc.path)
      expect(File.exist?(doc.path)).to be true
      doc.delete_file
      expect(File.exist?(doc.path)).to be false
    end
    it "returns nil if doc file does not exist" do
      doc = build(:document)
      expect(doc.delete_file).to be nil
    end
  end

  describe '#build' do
    before :each do
      allow_any_instance_of(PDFBuilder).to  receive(:build)
      allow_any_instance_of(HTMLBuilder).to receive(:build)
      allow_any_instance_of(MOBIBuilder).to receive(:build)
      allow_any_instance_of(EPUBBuilder).to receive(:build)
      allow_any_instance_of(Document).to    receive(:upload)
    end
    it "instantiates PDFBuilder  if extension is pdf"  do
      expect(PDFBuilder).to receive_message_chain(:new, :build)
      build(:document, extension: 'pdf').build
    end
    it "instantiates HTMLBuilder if extension is html" do
      expect(HTMLBuilder).to receive_message_chain(:new, :build)
      build(:document, extension: 'html').build
    end
    it "instantiates MOBIBuilder if extension is mobi" do
      expect(MOBIBuilder).to receive_message_chain(:new, :build)
      build(:document, extension: 'mobi').build
    end
    it "instantiates EPUBBuilder if extension is epub" do
      expect(EPUBBuilder).to receive_message_chain(:new, :build)
      build(:document, extension: 'epub').build
    end
    it "changes extension to zip if it is html" do
      doc = build(:document, extension: 'html')
      doc.build
      expect(doc.extension).to eq 'zip'
    end
    it "uploads after building" do
      doc = build(:document, extension: 'html')
      expect(doc).to receive(:upload)
      doc.build
    end
  end

  describe '#upload' do
    before :each do
      allow_any_instance_of(Document).to receive(:build)
      @doc = create(:document)
      FileUtils.touch(@doc.path)
      @aws_object = S3_BUCKET.objects["documents/#{@doc.filename}.#{@doc.extension}"]
      @doc.upload
    end
    it "uploads document to documents folder on AWS" do
      expect(@aws_object.exists?).to be true
    end
    it "updates document record with AWS url and key" do
      expect(@doc.aws_url).to eq(@aws_object.public_url.to_s)
      expect(@doc.aws_key).to eq(@aws_object.key)
    end
  end
end
