module RedisHelper

  def self.reset_ratelimit_timestamp
    # Will return the timestamp
    rate_limit_timer = {:most_recent_request => Time.now}.to_json
    p $redis.set('ratelimit_timers', rate_limit_timer)
    return JSON.parse($redis.get('ratelimit_timers'))
  end

  def self.save_ratelimit(ratelimit)
    # This uses Redis
    post = $redis.set('ratelimit', ratelimit)
    if post === 'OK'
      return JSON.parse($redis.get('ratelimit'))
    else
      p 'Failed to reset the ratelimit timestamp.'
    end
  end

  # This will expect a query object constructed in #decode_ratelimit.

  def self.rate_limited?
    ratelimit = JSON.parse($redis.get('ratelimit'))

    Time.parse(ratelimit["seconds"]["most_recent_request"]).year

    # If there is a clear ratelimit
    if self.clear_ratelimit
      if ratelimit["seconds"]["used"] >= ratelimit['seconds']['limit']
        {error: "More than 10 requests in 10 seconds."}
      elsif ratelimit["ten_minutes"]["used"] >= ratelimit['ten_minutes']['limit']
        {error: "More than 600 requests in 10 minutes."}
      else
        false
      end
    else
      false
    end
  end

  def self.clear_ratelimit
    # This needs to be debugged. The timestamps are not consistent or something.
    # Might have to do with the ordering of to_i in the timestamp check stuff

    ratelimits = JSON.parse($redis.get('ratelimit'))

    # Epoch Time
    stored_timestamp = Date.parse(JSON.parse($redis.get('ratelimit_timers'))["most_recent_request"]).to_time.to_i

    if ratelimits.key?("seconds")
      seconds_limit = Date.parse(ratelimits["seconds"]["most_recent_request"]).to_time.to_i

      is_not_over_ratelimit = ratelimits["seconds"]["used"].to_time.to_i < ratelimits["seconds"]["limit"].to_time.to_i 
      does_not_need_to_update = (stored_timestamp - seconds_limit) > 10 || stored_timestamp == seconds_limit

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the seconds test"
      else
        return false
      end
    end
    
    if ratelimits.key?("ten_minutes")
      tens_limit = Date.parse(ratelimits["ten_minutes"]["most_recent_request"]).to_time.to_i

      # ! 
      is_not_over_ratelimit = ratelimits["ten_minutes"]["used"].to_time.to_i < ratelimits["ten_minutes"]["limit"].to_time.to_i 
      does_not_need_to_update = (stored_timestamp - tens_limit) > 600 || stored_timestamp == tens_limit

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the ten minute test"
      elsif !does_not_need_to_update
        self.reset_ratelimit_timestamp
      elsif !is_not_over_ratelimit
        p 'Over ratelimit'
        return false
      else
        p 'Resetting the ratelimit...'
        return false
      end      
    end

    return true

  end

end