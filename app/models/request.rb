class Request < ApplicationRecord
  belongs_to :story, required: false
  validates :url, presence: true

  
end
