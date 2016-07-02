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

end
