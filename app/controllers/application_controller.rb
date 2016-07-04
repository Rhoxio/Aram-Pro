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
    def self.get_recent_matches(summoner_id, opts = {})
      include_timeline = opts['timeline'] || false

      matches = "https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/#{summoner_id}/recent?api_key=#{ENV['RIOT_KEY']}"
      response = HTTParty.get(matches)
      recent_matches = response.parsed_response

      if response.success?

        recent_aram_data = []

        recent_matches["games"].each do |game|
          if game["gameMode"] && game["mapId"] === 12

            players = game["fellowPlayers"]

            # Pushing the current player in to the player array with the same formatting as fellowPlayers.
            players.push({"summonerId" => recent_matches["summonerId"], "teamId" => game['teamId'], "championId"=> game['championId'] })

            recent_aram_data.push({game_id: game["gameId"], players: players })

          end
        end

        all_matches = []

        recent_aram_data.each do |match|
          match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match[:game_id]}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
          match_response = HTTParty.get(match_url)
          parsed_response = match_response.parsed_response

          if match_response.success?
            all_matches.push({match_data: parsed_response, players: match[:players]})
          else
            self.handle_response(response)
          end
        end

        # If the loop above threw no errors...
        return all_matches
      else 
        p "Riot responded with a #{response.code}: #{response}"
        self.handle_response(response)
      end    


    end

    def self.get_match(match_id, opts = {})
      include_timeline = opts['timeline'] || false

      match_url = "https://na.api.pvp.net/api/lol/na/v2.2/match/#{match_id}?includeTimeline=#{include_timeline}&api_key=#{ENV['RIOT_KEY']}"
      response = HTTParty.get(match_url)

      # Since we are making only a single request, the match will come out as an error object or the parsed response. 
      parsed_response = response.parsed_response

      if response.success?
        parsed_response
      else
        self.handle_response(response)
      end

    end

    def self.handle_response(response)
      # This method expects a HTTParty response object. Intent is to return a handled parsed response if no error is thrown.
      case response.code
        when 200
          {error: 'Got a 200. Something went really wrong.', status: response.code}
        when 404
          {error: 'Data not found.', status: response.code}
        when 429
          {error: 'Rate Limit Reached', status: response.code}
        when 500..600
          {error: 'Riot API is having an issue.', status: response.code}
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
