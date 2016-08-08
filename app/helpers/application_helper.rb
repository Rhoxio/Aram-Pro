module ApplicationHelper

  def self.parse_ratelimit(headers)
    # One call made. Will return dynamic ratelimit.
    # X-Rate-Limit-Count: 1:1,1:10,1:600,1:3600

    # So I can just insert values right in
    p headers

    rate_limits = {
      :seconds => {:used => nil, :limit => nil, :most_recent_request => nil},
      :ten_minutes => {:used => nil, :limit => nil, :most_recent_request => nil}
    }

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
    # p rate_limits
    return rate_limits.to_json
  end

end
