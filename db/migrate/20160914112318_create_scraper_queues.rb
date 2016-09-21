class CreateScraperQueues < ActiveRecord::Migration[5.0]
  def change
    create_table :scraper_queues do |t|
      t.string :domain
      t.datetime :last_access
      t.string :queue, array: true, default: []
      t.timestamps
    end
  end
end
