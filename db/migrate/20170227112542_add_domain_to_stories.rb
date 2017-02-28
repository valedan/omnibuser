class AddDomainToStories < ActiveRecord::Migration[5.0]
  def change
    add_column :stories, :domain, :string
  end
end
