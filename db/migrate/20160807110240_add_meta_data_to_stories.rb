class AddMetaDataToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :meta_data, :string
  end
end
