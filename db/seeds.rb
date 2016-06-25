# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


# Have to populate the local database with champion info for easy access.
request = "http://ddragon.leagueoflegends.com/cdn/6.12.1/data/en_US/champion.json"
response = HTTParty.get(request)
champions = response.parsed_response

champ_tiers = {
	"god" => ["Varus", "Sona", "Lux", "Teemo", "Jayce"],
	"very_strong" => ["Annie", "Alistar", "Amumu", "Ashe", "Aurelion Sol", "Azir", "Brand", "Caitlyn", "Darius", "Ekko", "Ezreal", "Fiddlesticks", "Fizz", "Galio", "Heimerdinger", "Janna", "Karma", "Kayle", "Kennen", "LeBlanc", "Malphite", "Morgana", "Nidalee", "Rumble", "Sion", "Soraka", "Swain", "Vel’koz", "Vladimir", "Volibear", "Ziggs", "Miss Fortune", "Nautilus"],
	"strong" => ["Anivia", "Blitzcrank", "Cho’Gath", "Dr. Mundo", "Draven", "Ahri", "Garen", "Gragas", "Irelia", "Jax", "Jhin", "Katarina", "Kog’Maw", "Lissandra", "Malzahar", "Maokai", "Master Yi", "Sivir", "Shaco", "Tahm Kench", "Talon", "Thresh", "Veigar", "Viktor", "Wukong", "Xerath", "Yasuo", "Zyra", "Zilean"],
	"average" => ["Akali", "Bard", "Braum", "Cassiopeia", "Elise", "Fiora", "Gangplank", "Gnar", "Graves", "Illaoi", "Jinx", "Kalista", "Kha’zix", "Kindred", "Lucian", "Lulu", "Olaf", "Orianna", "Rammus", "Rek’Sai", "Renekton", "Rengar", "Riven", "Ryze", "Sejuani", "Syndra", "Tristana", "Xin Xhao", "Zac", "Zed", "Nami"],
	"below_average" => ["Corki", "Diana", "Hecarim", "Jarvan IV", "Karthus", "Kassadin", "Lee Sin", "Leona", "Nocturne", "Pantheon", "Poppy", "Quinn", "Shen", "Shyvana", "Singed", "Skarner", "Taliyah", "Vayne", "Vi", "Warwick", "Yorick", "Mordekaiser", "Nasus"],
	"weak" => ["Evelynn", "Nunu"],
	"very_weak" => ['Aatrox']	
}

champions["data"].each do |name, attributes|
	champion = Championbase.new()
	champion.name = attributes["name"]
	champion.title = attributes["title"]
	champion.champion_id = attributes["key"]
	champion.blurb = attributes["blurb"]

	champion.image = attributes["image"]["full"]
	champion.riot_tags = attributes["tags"]

	champion.stats = attributes["stats"]
	champion.other_tags = []

	if champ_tiers["god"].include?(champion.name)
		champion.other_tags << 'god'
		champion.rating = 100
	elsif champ_tiers["very_strong"].include?(champion.name)
		champion.other_tags << 'very_strong'
		champion.rating = 90
	elsif champ_tiers["strong"].include?(champion.name)
		champion.other_tags << 'strong'
		champion.rating = 80
	elsif champ_tiers["average"].include?(champion.name)
		champion.other_tags << 'average'
		champion.rating = 70
	elsif champ_tiers["below_average"].include?(champion.name)
		champion.other_tags << 'below_average'
		champion.rating = 60
	elsif champ_tiers["weak"].include?(champion.name)
		champion.other_tags << 'weak'
		champion.rating = 50
	elsif champ_tiers["very_weak"].include?(champion.name)
		champion.other_tags << 'very_weak'
		champion.rating = 35
	else
		champion.other_tags << 'not_ranked'
	end		

	if champion.save
		p "#{champion.name} saved!"
	else
		p "Something went wrong..."
	end
end



