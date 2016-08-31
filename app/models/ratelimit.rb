class Ratelimit

  def self.initialize_ratelimit
    initial_ratelimit = {
      :seconds => {:used => 'none', :limit => 'none', :most_recent_request => Time.now.to_i},
      :ten_minutes => {:used => 'none', :limit => 'none', :most_recent_request => Time.now.to_i}
    }.to_json

    res = $redis.set('ratelimit', initial_ratelimit)

    if res == "OK"
      return JSON.parse($redis.get('ratelimit_timers'))
    else
      return {error: 'Redis save failed.', msg: res}
    end
  end

  def self.parse_ratelimit(headers)
    # One call made. Will return hashed ratelimit.
    # X-Rate-Limit-Count: 1:1,1:10,1:600,1:3600
    rate_limits = {
      :seconds => {:used => nil, :limit => nil, :most_recent_request => nil},
      :ten_minutes => {:used => nil, :limit => nil, :most_recent_request => nil}
    }

    if headers['x-rate-limit-count'] != nil
      headers['x-rate-limit-count'].split(',').each_with_index do |limit, index|
        # I will add more when I get a prod key.
        if index == 0
          rate_limits[:seconds][:used] = limit.split(':')[0]
          rate_limits[:seconds][:limit] = limit.split(':')[1]
          rate_limits[:seconds][:most_recent_request] = Time.now.to_i
        elsif index == 1
          rate_limits[:ten_minutes][:used] = limit.split(':')[0]
          rate_limits[:ten_minutes][:limit] = limit.split(':')[1]
          rate_limits[:ten_minutes][:most_recent_request] = Time.now.to_i
        end
      end
      return rate_limits.to_json
    else
      return {error: "No rate limit header present."}.to_json
    end
  end  

  def self.reset_ratelimit_timestamp
    # Will return the timestamp
    rate_limit_timer = {:most_recent_request => Time.now.to_i}.to_json
    $redis.set('ratelimit_timers', rate_limit_timer)
    return JSON.parse($redis.get('ratelimit_timers'))
  end

  # Save 
  def self.save_ratelimit_as_json(headers)
    # Before saving them, we need to parse.
    ratelimit = self.parse_ratelimit(headers)

    if !JSON.parse(ratelimit).key?('error')
      post = $redis.set('ratelimit', ratelimit)
      
      if post === 'OK'
        return JSON.parse($redis.get('ratelimit'))
      else
        p 'Failed to reset the ratelimit timestamp.'
        return false
      end
    else
      return JSON.parse($redis.get('ratelimit'))
    end
  end

  def self.rate_limited?
    ratelimit = JSON.parse($redis.get('ratelimit'))

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
    ratelimits = JSON.parse($redis.get('ratelimit'))

    # Epoch Time
    stored_timestamp = JSON.parse($redis.get('ratelimit_timers'))["most_recent_request"].to_i

    if ratelimits.key?("seconds")
      seconds_limit = ratelimits["seconds"]["most_recent_request"].to_i

      is_not_over_ratelimit = ratelimits["seconds"]["used"] < ratelimits["seconds"]["limit"] 
      does_not_need_to_update = (stored_timestamp - seconds_limit) > 10 || stored_timestamp == seconds_limit

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the seconds test"
      else
        return false
      end
    end
    
    if ratelimits.key?("ten_minutes")
      tens_limit = ratelimits["ten_minutes"]["most_recent_request"].to_i

      is_not_over_ratelimit = ratelimits["ten_minutes"]["used"].to_i < ratelimits["ten_minutes"]["limit"].to_i
      does_not_need_to_update = (stored_timestamp - tens_limit) > 600 || stored_timestamp == tens_limit

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the ten minute test"
      elsif !does_not_need_to_update
        self.reset_ratelimit_timestamp
      elsif !is_not_over_ratelimit
        p 'Over ratelimit'
        return false
      else
        return false
      end      
    end

    return true

  end
end