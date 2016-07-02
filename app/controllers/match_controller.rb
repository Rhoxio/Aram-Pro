class MatchController < ApplicationController
	respond_to :json, :html

	def get_one
		if params[:id] && current_user

			match = Match.find_by(match_id:params[:id])

			respond_to do |format|
		    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
		  end	

		else

			if !current_user
				error = {error: "User not logged in."}
			elsif !params[:id]
				error = {error: "Param not spcified"}
			else
				error = {error: "Error occured."}
			end

			respond_to do |format|
		    format.json{render :json => error }
		  end	

		end
	end

	def create
	end

	def current_match

		if params[:summoner_id]

			match_request = "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/#{params[:summoner_id]}?api_key=#{ENV['RIOT_KEY']}"
			response = HTTParty.get(match_request)
			parsed_response = response.parsed_response

			# If the response is 200...
			case response.code
				when 200
					new_match = Match.new()
					if new_match.build_from_current_match(parsed_response, current_user)

					  respond_to do |format|
					    format.json{render :json => new_match, :include =>[:champions => {:include => :championbase}] }
					  end	

					else
						# The match existed already.
						match = Match.find_by(match_id: new_match.match_id)

					  respond_to do |format|
					    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
					  end			
					end

				# If the request 404s...
				when 404
					p 'User was not in game.'

					error = {error: 'No current game.', status: 404}			

				  respond_to do |format|
				    format.json{render :json => error }
				  end

				  # If the rate limit is exceeded...
				 when 429
				 	p 'Rate limit exceeded'	
				 	error = {error: 'Rate limit exceeded.', status: 429}	

				  respond_to do |format|
				    format.json{render :json => error }
				  end				 	
				 end		
		else
		  respond_to do |format|
		    format.json{render :json => {error: 'No summoner id.'} }
		  end		
		end

	end

	def recent_matches
		if params[:summoner_id]
			matches = "https://na.api.pvp.net/api/lol/na/v1.3/game/by-summoner/#{params[:summoner_id]}/recent?api_key=#{ENV['RIOT_KEY']}"
			response = HTTParty.get(matches)
			recent_matches = RiotAPI.handle_response(response)

			# p recent_matches

			if !recent_matches[:error]

				recent_aram_ids = []

				recent_matches[:response]["games"].each do |game|
					if game["gameMode"] && game["mapId"] === 12
						recent_aram_ids.push(game["gameId"])
					end
				end

				# p recent_aram_ids

				recent_arams = RiotAPI.get_matches(recent_aram_ids)

				# p recent_arams

				if !recent_arams.is_a?(Hash)
					respond_to do |format|
				    format.json{render :json => recent_arams}
				  end
				elsif recent_arams.is_a?(Hash)
					p recent_arams
					respond_to do |format|
				    format.json{render :json => recent_arams}
				  end					
				end

			 else
			 	#There was some kind of error. 
			 	p recent_matches
			 	respond_to do |format|
			    format.json{render :json => recent_matches}
			  end
			 end	


		end
	end

	def processed_match
		if params[:match_id]
		  # respond_to do |format|
		  #   format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
		  # end		
		else
			# respond_to do |format|
		 #    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
		 #  end		
		end
	end

end
