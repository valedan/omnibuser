class AddCurrentChaptersToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :current_chapters, :integer
  end
end
