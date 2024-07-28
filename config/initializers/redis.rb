# config/initializers/redis.rb

redis_config = { url: ENV['REDIS_URL'] }

# $redis = Redis::Namespace.new('vedoc_api', redis: Redis.new(redis_config))
$redis = Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0")
