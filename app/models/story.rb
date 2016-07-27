class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :documents, dependent: :destroy
  has_many :requests

  def build
    @doc = Document.create(story_id: self.id, filename: self.title,
                           extension: 'html')
    DocumentCleanupJob.set(wait: 10.minutes).perform_later(@doc)
    @doc.id
  end
end
