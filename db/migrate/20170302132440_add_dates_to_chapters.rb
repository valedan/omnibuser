class AddDatesToChapters < ActiveRecord::Migration[5.0]
  def change
    add_column :chapters, :publish_date, :date
    add_column :chapters, :edit_date, :date
  end
end
