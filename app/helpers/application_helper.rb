module ApplicationHelper

  def self.decode_ratelimit(headers)
    # One call made. Will retur dynamic ratelimit.
    # X-Rate-Limit-Count: 1:1,1:10,1:600,1:3600

    # So I can just insert values right in
    rate_limits = {
      :seconds => {:used => nil, :limit => nil},
      :ten_minutes => {:used => nil, :limit => nil}
    }

    headers['x-rate-limit-count'].split(',').each_with_index do |limit, index|
      # p limit.split(':')
      # I will add more 
      if index == 0
        rate_limits[:seconds][:used] = limit.split(':')[0]
        rate_limits[:seconds][:limit] = limit.split(':')[1]
      elsif index == 1
        rate_limits[:ten_minutes][:used] = limit.split(':')[0]
        rate_limits[:ten_minutes][:limit] = limit.split(':')[1]
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
    ratelimit = $redis.get('ratelimit')

    if ratelimit["seconds"]["used"] >= ratelimit['seconds']['limit']
      return {error: "More than 10 requests in 10 seconds."}
    elsif ratelimit["ten_minutes"]["used"] >= ratelimit['ten_minutes']['limit']
      return {error: "More than 600 requests in 10 minutes."}
    # elsif ratelimit["seconds"]["used"] <= ratelimit['seconds']['limit']
    #   check_if_it_has_been_enough_time_to_reset_the_limit
    # elsif ratelimit["ten_minutes"]["used"] >= ratelimit['ten_minutes']['limit']
    #   check_if_it_has_been_enough_time_to_reset_the_limit
    else
      return false
    end
  end

end
