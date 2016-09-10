class AddExtensionToRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :extension, :string
  end
end
