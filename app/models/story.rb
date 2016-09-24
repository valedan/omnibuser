class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :requests

  def build(ext)
    puts "story before doc create"
    @doc = Document.create(story_id: self.id, filename: self.title,
                           extension: ext)

    puts "story after doc create"
    @doc.id
  end
end
