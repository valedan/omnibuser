class Story < ApplicationRecord
  has_many :chapters, dependent: :destroy
  has_many :requests

  def build

  end
end
