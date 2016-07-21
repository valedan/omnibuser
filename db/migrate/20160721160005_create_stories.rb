class CreateStories < ActiveRecord::Migration[5.0]
  def change
    create_table :stories do |t|
      t.string :url
      t.string :title
      t.string :author

      t.timestamps
    end
  end
end
