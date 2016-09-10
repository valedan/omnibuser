class Chapter < ApplicationRecord
  belongs_to :story
  validates :number, uniqueness: {scope: :story_id}
end
