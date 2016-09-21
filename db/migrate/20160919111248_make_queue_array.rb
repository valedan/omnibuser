class MakeQueueArray < ActiveRecord::Migration[5.0]
  def change
    add_column :scraper_queues, :queue, :string, array: true, default: []
  end
end
