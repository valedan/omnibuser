class RemoveCurrentChapterFromRequests < ActiveRecord::Migration[5.0]
  def change
    remove_column :requests, :current_chapter, :integer
  end
end
