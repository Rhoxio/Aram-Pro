include RedisHelper
$redis = Redis.new(:host => 'localhost', :port => 6379)
Ratelimit.initialize_ratelimit