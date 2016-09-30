class AddAwsUrltoRequests < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :aws_url, :string
  end
end
