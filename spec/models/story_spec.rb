require 'rails_helper'

describe Story do
  it { should have_many(:chapters).dependent(:destroy) }
  it { should have_many(:documents).dependent(:destroy) }
  it { should have_many(:images).dependent(:destroy) }
  it { should have_one(:request) }

  before :all do
    @story  = create(:story)
    @image1 = create(:image, story_id: @story.id, source_url: 'url1')
    @image2 = create(:image, story_id: @story.id, source_url: 'url2')
    @cover_image = create(:cover_image, story_id: @story.id, source_url: 'url2')
    @smilies = create(:image, story_id: @story.id, source_url: 'styles/sv_smiles')
  end

  describe '#build' do
    before :each do
      allow_any_instance_of(Document).to receive(:build)
      allow_any_instance_of(Document).to receive(:sanitize_filename)
    end

    it "creates a Document" do
      expect{@story.build('html')}.to change(Document, :count).by(1)
    end

    it "sets Document attributes correctly" do
      document = Document.find(@story.build('html'))
      expect(document.story_id).to  eq(@story.id)
      expect(document.filename).to  eq(@story.title)
      expect(document.extension).to eq('html')
    end

    it "returns the doc id" do
      expect(@story.build('html')).to eq(Document.last.id)
    end
  end

  describe '#cover_image' do
    it "returns the cover image" do
      expect(@story.cover_image).to eq(@cover_image)
    end
  end
  describe '#has_image' do
    it "returns the image at specified url" do
      expect(@story.has_image('url1')).to eq(@image1)
    end
    it "does not return a cover image" do
      expect(@story.has_image('url2')).to eq(@image2)
    end
    it "returns nil if no match found" do
      expect(@story.has_image('url3')).to be_nil
    end
  end

  describe '#add_domain' do
    it "sets domain based on url" do
      expect(create(:ffn_story).domain).to eq('ffn')
      expect(create(:fp_story).domain).to  eq('fp')
      expect(create(:sv_story).domain).to  eq('sv')
      expect(create(:sb_story).domain).to  eq('sb')
      expect(create(:qq_story).domain).to  eq('qq')
      expect(create(:story, url: 'bad_url').domain).to be_nil
    end
  end
end
