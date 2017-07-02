class AddTargetToRequests < ActiveRecord::Migration[5.0]
  def change
    add_reference :requests, :target, foreign_key: true
  end
end
