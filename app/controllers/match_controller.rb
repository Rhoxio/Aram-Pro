class MatchController < ApplicationController
	respond_to :json, :html

	def get_one
		if params[:id] && current_user

			match = Match.find_by(match_id:params[:id])

			respond_to do |format|
		    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
		  end	

		else

		end
	end

	def create
	end

	def current_match

		if params[:summoner_id]

			match_request = "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/#{params[:summoner_id]}?api_key=#{ENV['RIOT_KEY']}"
			response = HTTParty.get(match_request)
			parsed_response = response.parsed_response

			# If the response is 202...
			case response.code
				when 200

					new_match = Match.new()
					new_match.match_id = parsed_response['gameId']
					new_match.platform_id = parsed_response['platformId']
					new_match.user = current_user

					parsed_response['participants'].each do |participant|
						spell_1 = participant['spell1Id']
						spell_2 = participant['spell2Id']

						base = Championbase.find_by(champion_identifier: participant['championId'])

						new_match.champions.build(
							champion_identifier: participant['championId'],
							summoner_identifier: participant['summonerId'], 
							masteries: participant['masteries'],
							runes: participant['runes'],
							summoner_spells: [spell_1, spell_2],
							team: participant['teamId'],
							name: base.name,
							image: "http://ddragon.leagueoflegends.com/cdn/6.12.1/img/champion/#{base.image}",
							championbase: base
						)
					end

					if new_match.save
						p 'Match was saved!'

						match = Match.find_by(match_id: new_match.match_id)

					  respond_to do |format|
					    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
					  end	

					else
						p 'Match was not saved.'

						match = Match.find_by(match_id: new_match.match_id)				

					  respond_to do |format|
					    format.json{render :json => match, :include =>[:champions => {:include => :championbase}] }
					  end			
					end

				# If the request 404s...
				when 404
					p 'User was not in game.'

					error = {error: 'No current game.'}			

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
