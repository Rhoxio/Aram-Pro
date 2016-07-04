class Match < ActiveRecord::Base
	validates_uniqueness_of :match_id
	belongs_to :user

	has_many :champions

 	def process_champions
 	end

 	def build_from_current_match(match, current_user)
 		#This is a creative method. It will save a new model and return the result. 
		self.match_id = match['gameId']
		self.platform_id = match['platformId']
		self.user = current_user

		match['participants'].each do |participant|
			spell_1 = participant['spell1Id']
			spell_2 = participant['spell2Id']

			base = Championbase.find_by(champion_identifier: participant['championId'])

			self.champions.build(
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

			if self.save
				puts "Match was built and saved!"
				return self
			else
				puts "Match attempted to be built and already existed."
				return false
			end
		end	
 	end

 	def self.build_from_recent_matches(matches, current_user)

 		# Assigning each participant their summoner ID based on the champion they played.
 		# This works due to the fact that there will be no duplicate champions in an ARAM game.
 		player_sorted_matches = matches.map do |match|
 			match[:players].each do |player|
 				match[:match_data]["participants"].each do |participant|
 					if participant['championId'] == player['championId']
 						participant['summonerId'] = player['summonerId']
 					end
 				end
 			end
 			match
 		end

 		# Where all of the matches are going to be pushed to in the loop below...
 		all_matches = Array.new

		player_sorted_matches.each do |match|
			# To make this less confusing it should really just be called a match now. No need for the players hash.
			match = match[:match_data]

			# Create a match scaffold and start assigning.
			new_match = Match.new
			new_match.match_id = match['matchId']
			new_match.platform_id = match['platformId']
			new_match.user = current_user

			match['participants'].each do |participant|
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

			# If it saves, push it to the array to be returned.
			if new_match.save
				puts "Match was built and saved!"
				all_matches.push(new_match)
			else
				puts "Match attempted to be built and already existed."
			end 
		end

		if all_matches.length > 1
			return all_matches
		else
			return {status: 'No matches created.'}
		end
 	end

end
