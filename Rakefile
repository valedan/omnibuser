# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'
require 'resque/pool/tasks'

Rails.application.load_tasks

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do
    ActiveRecord::Base.establish_connection
  end
end
