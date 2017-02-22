class CreateImages < ActiveRecord::Migration[5.0]
  def change
    create_table :images do |t|
      t.belongs_to :story, index:true
      t.string :source_url
      t.string :aws_url
      t.string :filename
      t.string :extension
      t.integer :size
      t.boolean :cover

      t.timestamps
    end
  end
end
