class AddAwsKeyToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :aws_key, :string

  end
end
