include RedisHelper
$redis = Redis.new(:host => 'localhost', :port => 6379)
$analytics = Redis::Namespace.new(:analytics, :redis => $redis)
Ratelimit.initialize_ratelimit