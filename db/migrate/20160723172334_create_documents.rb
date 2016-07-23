class CreateDocuments < ActiveRecord::Migration[5.0]
  def change
    create_table :documents do |t|
      t.belongs_to :story, index:true
      t.string :filename
      t.string :extension

      t.timestamps
    end
  end
end
