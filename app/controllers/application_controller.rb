class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :logged_in?
  helper_method :current_user
  include ApplicationHelper
  include RedisHelper

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

    def self.get_current_match(summoner_id)

      if RedisHelper.rate_limited?
        return {error: 'Ratelimit exceeded.'}  
      else
        match_request = "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/#{summoner_id}?api_key=#{ENV['RIOT_KEY']}"
        response = HTTParty.get(match_request)
        redis_ratelimit = RedisHelper.save_ratelimit_as_json(response.headers)

        if response.success?
          return response 
        else
          return self.handle_error_response(response)
        end
      end
    end

    def self.get_recent_matches(summoner_id, opts = {})
      include_timeline = opts['timeline'] || false

      if RedisHelper.rate_limited?
        return {error: 'Ratelimit exceeded.'} 
      else
        matches = "https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/#{summoner_id}/recent?api_key=#{ENV['RIOT_KEY']}"
        response = HTTParty.get(matches)
        recent_matches = response.parsed_response
        redis_ratelimit = RedisHelper.save_ratelimit_as_json(response.headers) 

        if response.success?

          recent_aram_data = []

          recent_matches["games"].each do |game|
            if game["gameMode"] == "ARAM" && game["mapId"] === 12

              players = game["fellowPlayers"]
              # Pushing the current player in to the player array with the same formatting as fellowPlayers.
              players.push({"summonerId" => recent_matches["summonerId"], "teamId" => game['teamId'], "championId"=> game['championId'] })
              recent_aram_data.push({game_id: game["gameId"], players: players })

            end
          end

          all_matches = []

          recent_aram_data.each do |match|
            if Match.exists?(:match_id => match[:game_id])
              p 'Match already existed.'
            else
              # Make the API Call if there is no ratelimit restrictions
              if RedisHelper.rate_limited?
                p 'Hit the ratelimit.'
                return all_matches
              else
                # Get the match. 
                match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match[:game_id]}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
                response = HTTParty.get(match_url)
                parsed_response = response.parsed_response
                redis_ratelimit = RedisHelper.save_ratelimit_as_json(response.headers)

                if response.success?
                  all_matches.push({match_data: parsed_response, players: match[:players]})
                else
                  if all_matches.length > 1
                    return all_matches
                  else
                    return self.handle_error_response(parsed_response)
                  end
                end
              end
            end
          end

          # If the loop above threw no errors...
          p all_matches
          return all_matches
        else 
          self.handle_error_response(response)
        end
      end
    end

    def self.get_match(match_id, opts = {})
      include_timeline = opts['timeline'] || false

      if RedisHelper.rate_limited?
        return {error: 'Ratelimit exceeded.'} 
      else
        match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match_id}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
        response = HTTParty.get(match_url)
        redis_ratelimit = RedisHelper.save_ratelimit_as_json(response.headers)
        parsed_response = response.parsed_response

        if response.success?
          parsed_response
        else
          self.handle_error_response(response)
        end
      end
    end

    def self.get_summoners(ids)

      if RedisHelper.rate_limited?
        return {error: 'Ratelimit exceeded.'} 
      else
        summoner_ids = ''
        ids.each do |id| 
          # Formats the ids for the request
          summoner_ids += "#{id},"
        end

        summoners_uri = "https://na.api.pvp.net/api/lol/na/v1.4/summoner/#{summoner_ids}?api_key=#{ENV['RIOT_KEY']}"
        response = HTTParty.get(summoners_uri)
        redis_ratelimit = RedisHelper.save_ratelimit_as_json(response.headers)

        if response.success?
          parsed_response
        else
          self.handle_error_response(response)
        end
      end      

    end

    def self.handle_error_response(response, msg='Unspecified error.')
      # This method expects a HTTParty response object.
      case response.code
        when 200
          {error: msg, status: response.code}
        when 400
          {error: 'Bad request.', status: response.code}          
        when 401
          {error: 'Not authorized.', status: response.code}          
        when 404
          {error: 'Data not found.', status: response.code}
        when 429
          {error: 'Rate Limit Reached', status: response.code}
        when 500..600
          {error: 'Riot API is having an issue.', status: response.code}
        else
          {error: msg, status: response.code}
      end
    end

    def self.region_converter(region)
      if region == "br"
          "br"
      elsif region == "eune"
          "eun1"
      elsif region == "euw"
          "euw1"
      elsif region == "jp"
          "jp1"
      elsif region == "kr"
          "kr"
      elsif region == "lan"
          "la1"
      elsif region == "las"
          "la2"
      elsif region == "na"
          "na1"
      elsif region == "oce"
          "oc1"
      elsif region == "ru"
          "ru"
      else
          "tr1"
      end
    end   
  end
end
