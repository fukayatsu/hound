require 'resque/server'
require 'resque-retry'
require 'resque-sentry'
require 'resque/failure/redis'

if ENV["REDISTOGO_URL"]
  Resque.redis = Redis.new(url: ENV["REDISTOGO_URL"], thread_safe: true)
end

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  [user, password].join(':') == ENV['BASIC_AUTH']
end

Resque::Failure::Sentry.logger = 'resque'

Resque::Failure::MultipleWithRetrySuppression.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Sentry
]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression
