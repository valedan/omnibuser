class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :images, dependent: :destroy
  has_one :request

  after_create :add_domain

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

  def add_domain
    if    self.url.include?('fanfiction.net')
      self.update(domain: 'ffn')
    elsif self.url.include?('fictionpress.com')
      self.update(domain: 'fp')
    elsif self.url.include?('forums.sufficientvelocity.com')
      self.update(domain: 'sv')
    elsif self.url.include?('forums.spacebattles.com')
      self.update(domain: 'sb')
    elsif self.url.include?('forum.questionablequesting.com')
      self.update(domain: 'qq')
    else
      nil
    end
  end

end
