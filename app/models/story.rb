class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :requests

  def build
    @existing_doc = Document.find_by("story_id = ?", self.id)
    if @existing_doc
      @existing_doc.id
    else
      @doc = Document.create(story_id: self.id, filename: self.title,
                             extension: 'html')
      @doc.build
      @doc.id
    end
  end
end
