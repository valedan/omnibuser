require 'resque/tasks'
require 'resque/pool/tasks'

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
if Rails.env.development?
  task "resque:setup" => :environment do
    ENV['TERM_CHILD'] = '1'
    ENV['RESQUE_TERM_TIMEOUT'] = '10'
    # generic worker setup, e.g. Hoptoad for failed jobs
  end
end

if Rails.env.production?
  task "resque:setup" => :environment do
    ENV['TERM_CHILD'] = '1'
    ENV['RESQUE_TERM_TIMEOUT'] = '10'
  end

  desc "Alias for resque:work (To run workers on Heroku)"
  task "jobs:work" => "resque:work"
else
  task 'resque:setup' => :environment
end

task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  # and re-open them in the resque worker parent
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
  end
end

task "resque:pool:setup" do
  Resque::Pool.after_prefork do |job|
    Resque.redis.client.reconnect
  end
end
