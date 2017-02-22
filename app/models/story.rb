class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :requests

  def build(ext)
    @doc = Document.create(story_id: self.id, filename: self.title,
                           extension: ext)
    @doc.id
  end

  def cover_image
    self.images.find_by(cover: true)
  end

  def has_image(url)
    self.images.where(cover:false).find_by(source_url: url)
  end

  def list_images
    images = []
    self.chapters.each {|chapter| chapter.xhtml.search('img').each {|i| images << i['src']} }
    images.uniq!
    images.select{|i| !i.include?('styles/sv_smiles')}
  end
end
