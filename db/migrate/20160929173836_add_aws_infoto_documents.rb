class AddAwsInfotoDocuments < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :aws_url, :string
    add_column :documents, :aws_key, :string
  end
end
