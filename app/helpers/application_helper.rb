module ApplicationHelper

  def self.decode_ratelimit(headers)
    # One call made. Will retur dynamic ratelimit.
    # X-Rate-Limit-Count: 1:1,1:10,1:600,1:3600

    # So I can just insert values right in
    rate_limits = {
      :seconds => {:used => nil, :limit => nil, :most_recent_request => nil},
      :ten_minutes => {:used => nil, :limit => nil, :most_recent_request => nil}
    }

    headers['x-rate-limit-count'].split(',').each_with_index do |limit, index|
      # p limit.split(':')
      # I will add more. 
      if index == 0
        rate_limits[:seconds][:used] = limit.split(':')[0]
        rate_limits[:seconds][:limit] = limit.split(':')[1]
        rate_limits[:seconds][:most_recent_request] = Time.now
      elsif index == 1
        rate_limits[:ten_minutes][:used] = limit.split(':')[0]
        rate_limits[:ten_minutes][:limit] = limit.split(':')[1]
        rate_limits[:ten_minutes][:most_recent_request] = Time.now
      end
    end
    # p rate_limits
    return rate_limits.to_json
  end

  def self.save_ratelimit(ratelimit)
    # This uses Redis
    post = $redis.set('ratelimit', ratelimit)
    if(post === 'OK')
      return JSON.parse($redis.get('ratelimit'))
    else
      p 'Redis did not save.'
    end
  end

  # This will expect a query object constructed in #decode_ratelimit. 
  def self.rate_limited?
    ratelimit = JSON.parse($redis.get('ratelimit'))

    p Time.parse(ratelimit["seconds"]["most_recent_request"]).year
    # If there is a clear ratelimit
    if self.clear_ratelimit?
      if ratelimit["seconds"]["used"] >= ratelimit['seconds']['limit']
        return {error: "More than 10 requests in 10 seconds."}
      elsif ratelimit["ten_minutes"]["used"] >= ratelimit['ten_minutes']['limit']
        return {error: "More than 600 requests in 10 minutes."}
      else
        return false
      end
    else
      return false
    end
  end

  # 

  def self.reset_ratelimit_timestamp
    # Will return the timestamp
    rate_limit_timer = {:most_recent_request => Time.now}.to_json
    p $redis.set('ratelimit_timers', rate_limit_timer)
    return JSON.parse($redis.get('ratelimit_timers'))
  end

  def self.clear_ratelimit?
    # This needs to be debugged. The timestamps are not consistent or something.
    # MIght have to do with the ordering of to_i in the timestamp check stuff
    ratelimits = JSON.parse($redis.get('ratelimit'))
    stored_timestamp = Time.parse(JSON.parse($redis.get('ratelimit_timers'))["most_recent_request"])
    p ratelimits
    p stored_timestamp

    if ratelimits.key?("seconds")
      seconds_limit = Time.parse(ratelimits["seconds"]["most_recent_request"])

      is_not_over_ratelimit = ratelimits["seconds"]["used"].to_i < ratelimits["seconds"]["limit"].to_i 
      does_not_need_to_update = ((stored_timestamp - seconds_limit) * 24 * 60 * 60).to_i > 10

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the seconds test"
      else
        return false
      end
    end
    
    if ratelimits.key?("ten_minutes")
      seconds_limit = Time.parse(ratelimits["ten_minutes"]["most_recent_request"])

      is_not_over_ratelimit = ratelimits["ten_minutes"]["used"].to_i < ratelimits["ten_minutes"]["limit"].to_i
      does_not_need_to_update = ((stored_timestamp - seconds_limit) * 24 * 60 * 60).to_i > 600

      if does_not_need_to_update && is_not_over_ratelimit
        p "Passed the ten minute test"
      else
        return false
      end      
    end

    return true

  end

end
