$redis = Redis.new(:host => 'localhost', :port => 6379)
$redis.set('ratelimit', 'Not set.')