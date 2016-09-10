class AddProgressToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :status, :string
    add_column :requests, :current_chapter, :integer
    add_column :requests, :total_chapters, :integer
    add_column :requests, :complete, :boolean
  end
end
