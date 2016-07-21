class CreateChapters < ActiveRecord::Migration[5.0]
  def change
    create_table :chapters do |t|
      t.belongs_to :story, index: true
      t.integer :number
      t.string :title
      t.string :content

      t.timestamps
    end
  end
end
