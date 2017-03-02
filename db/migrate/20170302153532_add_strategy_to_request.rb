class AddStrategyToRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :requests, :strategy, :string
    add_column :requests, :recent_number, :integer
  end
end
