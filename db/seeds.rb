# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# class Riot
#   def self.get_all_champions
#     request = "http://ddragon.leagueoflegends.com/cdn/6.12.1/data/en_US/champion.json "
#     response = HTTParty.get(request)
#     champions = response.parsed_response

#     champions["data"].each do |name, attributes|
#     	puts name
#     	p attributes
#     	puts ''
#     end
#   end
# end  

# Riot.get_all_champions

request = "http://ddragon.leagueoflegends.com/cdn/6.12.1/data/en_US/champion.json"
response = HTTParty.get(request)
champions = response.parsed_response

champions["data"].each do |name, attributes|
	champion = Championbase.new()
	champion.name = attributes["name"]
	champion.title = attributes["title"]
	champion.champion_id = attributes["key"]

	champion.image = attributes["image"]["full"]
	champion.riot_tags = attributes["tags"]

	champion.stats = attributes["stats"]

	puts champion

	if champion.save
		p "#{champion.name} saved!"
	else
		p "Something went wrong..."
	end
end



