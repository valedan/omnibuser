require 'rails_helper'

describe Chapter do
  it { should belong_to(:story) }
  it { should validate_uniqueness_of(:number).scoped_to(:story_id) }

  describe '#ensure_title' do
    it "updates record with default title if title is blank" do
      chapter = create(:untitled_chapter)
      expect(chapter.title).to eq("Chapter #{chapter.number}")
    end
    it "does not change title if title is not blank" do
      chapter = create(:chapter, title: "Awesome Chapter")
      expect(chapter.title).to eq("Awesome Chapter")
    end
  end

  describe '#epub' do
    it "changes image src's to include correct path" do
      chapter = create(:chapter_with_images)
      expect(chapter.epub).to eq "<div><img src=\"../images/img1.jpg\"/>\n<img src=\"../images/img2.jpg\"/></div>"
    end
  end

  describe '#html' do
    it "changes image src's to include correct path" do
      chapter = create(:chapter_with_images)
      expect(chapter.html).to eq "<div><img src=\"files/images/img1.jpg\"/>\n<img src=\"files/images/img2.jpg\"/></div>"
    end
    it "does not alter image src if src is blank" do
      chapter = create(:chapter_with_srcless_images)
      expect(chapter.html).to eq "<div><img src=\"\"/>\n<img src=\"\"/></div>"
    end
  end

  describe '#xhtml' do
    it "returns a Nokogiri nodeset" do
      chapter = create(:chapter_with_images)
      expect(chapter.xhtml).to be_an_instance_of Nokogiri::XML::Document
    end
  end

end
