redis_config = { url: ENV[ 'REDIS_URL' ] }

Redis.current = Redis::Namespace.new 'vedoc_api', redis: Redis.new( redis_config )
