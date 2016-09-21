class RemoveQueueFromScraperQueues < ActiveRecord::Migration[5.0]
  def change
    remove_column :scraper_queues, :queue, :string
  end
end
