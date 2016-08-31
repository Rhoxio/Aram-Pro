class Analytics

  def self.new_entry(name, data)
    name = name.downcase
    data = data.to_json
    if $analytics.get(name).length <= 0
      post = $analytics.set(name, data)
      post == "OK" ? JSON.parse(data) : self.handle_error(data)
    else
      self.handle_error(data, "Entry for #{name} already existed.")
    end
  end

  def self.update(key, data)
    name = name.downcase
    data = data.to_json
    post = $analytics.set(name, data)
    post_data = $analytics.get(name)

    post == "OK" ? JSON.parse(post_data) : self.handle_error(data, "Could not update #{name}.") 
  end

  def self.get_keys
    keys = $analytics.keys("*")
    if keys.length > 0
      return keys
    else
      return self.handle_error(keys, "Count not find keys in Analytics.")
    end
  end

  def self.get(key, format = :default)
    data = $analytics.get(key)
    if data != nil
      if format == :json
        return data
      elsif format == :default
        return JSON.parse(data)
      end
    else
      return self.handle_error(data, "Could not find matching key (#{key}) in Analytics.")
    end
  end

  # PRIVATE METHODS STARTING
  private
  # JUST MAKING SURE YOU CAN SEE IT

  def self.handle_error(data, msg = '')
    if data == nil
      return {error: 'No data.', data: data, msg: msg}
    elsif data != nil
      return {error: "Other error occured.", data: data, msg: msg}
    end
  end

end