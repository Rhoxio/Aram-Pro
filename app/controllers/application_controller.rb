class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?
  helper_method :current_user

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorize
    redirect_to '/login' unless current_user
  end

  def logged_in?
    !!session[:user_id]
  end


  class RiotAPI
    def self.get_matches(match_ids, opts = {})
      include_timeline = opts['timeline'] || false
      all_matches = []

      match_ids.each do |match|
        match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
        response = HTTParty.get(match_url)
        parsed_response = self.handle_response(response)

        # Returns the error if one is thrown while making the API calls and breaks the loop.
        if !parsed_response[:error]
          all_matches.push(parsed_response[:response])
        else
           return parsed_response
        end
      end

      # If the loop above threw no errors...
      return all_matches

    end

    def self.get_match(match_id, opts = {})
      include_timeline = opts['timeline'] || false

      match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match_id}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
      response = HTTParty.get(match_url)

      # Since we are making only a single request, the match will come out as an error object or the parsed response. 
      parsed_response = self.handle_response(response)['response']

    end

    def self.handle_response(response)
      # This method expects a HTTParty response object. Intent is to return a handled parsed response if no error is thrown.
      case response.code
        when 200
          parsed_response = {response: response.parsed_response}
        when 404
          {error: 'Data not found.', status: response.code}
        when 429
          {error: 'Rate Limit Reached', status: response.code}
        when 500..600
          {error: 'Riot API is having an issue.', status: response.code}
      end

    end
  end

end
