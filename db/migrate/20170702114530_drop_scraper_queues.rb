class DropScraperQueues < ActiveRecord::Migration[5.0]
  def change
    drop_table :scraper_queues
  end
end
