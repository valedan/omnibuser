class Target < ApplicationRecord
  has_many :requests, dependent: :nullify
  validates :domain, presence: true, uniqueness: true

  after_create :touch
  after_create :load_target_data

  def touch
    self.update!(last_access: Time.now)
  end

  def scraper_class
    scraper.constantize
  end

  def load_target_data
    return if target_data
    yml = YAML.load(File.read(Rails.root.join('config', 'targets.yml')))
    self.update!(target_data: yml[domain])
  end
end
