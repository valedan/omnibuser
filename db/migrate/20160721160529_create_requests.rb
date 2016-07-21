class CreateRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :requests do |t|
      t.belongs_to :story, index: true
      t.string :url

      t.timestamps
    end
  end
end
