class MatchController < ApplicationController
	respond_to :json, :html

	def get
	end

	def create
	end

	def current_match

		if params[:summoner_id]

			match_request = "https://na.api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/NA1/#{params[:summoner_id]}?api_key=#{ENV['RIOT_KEY']}"
			response = HTTParty.get(match_request).parsed_response

			new_match = Match.new()
			new_match.match_id = response['gameId']
			new_match.platform_id = response['platformId']

			response['participants'].each do |participant|
				p participant
				spell_1 = participant['spell1Id']
				spell_2 = participant['spell2Id']

				p new_match.champions.build(champion_id: participant['championId'], 
																	summoner_id: participant['summonerId'], 
																	masteries: participant['masteries'], 
																	runes: participant['runes'],
																	summoner_spells: [spell_1, spell_2], 
																	team: participant['teamId']
																	)
			end

			p '-- New Match --'
			p new_match

			if new_match.save
				p 'Match was saved!'
				p match = Match.where(match_id: new_match.match_id.to_s)
			else
				p 'Match was not saved.'
				p match = Match.where(match_id: new_match.match_id.to_s)
			end

		  respond_to do |format|
		    format.json{render :json => response }
		  end

		else
		  respond_to do |format|
		    format.json{render :json => {error: 'No summoner id.'} }
		  end		
		end

	end

end
