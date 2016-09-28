class AddDocIdtoRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :doc_id, :integer
  end
end
