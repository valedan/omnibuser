class CreateProxies < ActiveRecord::Migration[5.0]
  def change
    create_table :proxies do |t|
      t.string :ip
      t.string :port
      t.string :username
      t.string :password
      t.integer :successful_request_count, default: 0
      t.integer :failed_request_count, default: 0
      t.datetime :last_successful_request
      t.timestamps
    end
  end
end
