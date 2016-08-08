include RedisHelper
$redis = Redis.new(:host => 'localhost', :port => 6379)
RedisHelper.initialize_ratelimit