class CreateTargets < ActiveRecord::Migration[5.0]
  def change
    create_table :targets do |t|
      t.string :domain
      t.datetime :last_access
      t.string :scraper
      t.json :target_data

      t.timestamps
    end
  end
end
