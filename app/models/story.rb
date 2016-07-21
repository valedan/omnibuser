class Story < ApplicationRecord
  has_many :chapters
  has_many :requests
end
