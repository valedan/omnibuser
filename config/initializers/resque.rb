Resque.logger = Logger.new(STDOUT)

require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque/rollbar'

Resque::Failure::Multiple.classes = [ Resque::Failure::Redis, Resque::Failure::Rollbar ]
Resque::Failure.backend = Resque::Failure::Multiple