class Championbase < ActiveRecord::Base
  serialize :stats

  has_many :champions
  validates :champion_identifier, uniqueness: true

  require 'open-uri'

  def self.scrape_for_champion_stats

    bases = Championbase.all
    bases.each do |champ|
      # Metasrc uses champion names formated like aurelionsol or khazix. All lower case, no spaces, no hyphens or apostrophes, no periods.
      formatted_champ_name = champ.name.gsub(/[. ']/, "").downcase

      doc = Nokogiri::HTML(open("http://www.metasrc.com/na/aram/champion/#{formatted_champ_name}"))

      champ.tier = doc.css('div#container div#stats table tr td')[0].text
      champ.score = doc.css('div#container div#stats table tr td')[1].text
      champ.win_rate = doc.css('div#container div#stats table tr td')[2].text.gsub('%', '').to_f
      champ.pick_rate = doc.css('div#container div#stats table tr td')[3].text.gsub('%', '').to_f
      champ.KDA = doc.css('div#container div#stats table tr td')[4].text.to_f

      if champ.save
        ap champ
      else
        p "Scrape for #{champ.name} failed."
      end
    end 
  end

  def self.seed_championbase_list
    request = "http://ddragon.leagueoflegends.com/cdn/6.16.2/data/en_US/champion.json"
    response = HTTParty.get(request)
    champions = response.parsed_response

    # Some champs with apostrophes are not populating correctly.
    champ_tags = {
      "heavy_cc" => ["Alistar", "Amumu", "Anivia", "Annie", "Ashe", "Braum", "Blitzcrank", "Cassiopeia", "Cho'Gath", "Elise", "Fiddlesticks", "Galio", "Gragas", "Janna", "Leona", "Lissandra", "Lux", "Malphite", "Malzahar", "Maokai", "Morgana", "Nami", "Nautilus", "Orianna", "Poppy", "Rammus", "Riven", "Ryze", "Sejuani", "Sion", "Sona", "Syndra", "Tahm'Kench", "Taric", "Thresh", "Twisted Fate", "Varus", "Veigar", "Vel’Koz", "Vi", "Warwick", "Zyra"],
      "tanky" => ["Alistar", "Amumu", "Aurelion Sol", "Braum", "Cho'Gath", "Darius", "Dr. Mundo", "Irelia", "Galio", "Garen", "Illaoi", "Gnar", "Gragas", "Hecarim", "Malphite", "Leona", "Maokai", "Nasus", "Nautilus", "Olaf", "Rek’Sai", "Rammus", "Renekton", "Sejuani", "Shyvana", "Singed", "Sion", "Skarner", "Swain", "Tahm Kench", "Taric", "Thresh", "Udyr", "Vi", "Vladimir", "Volibear", "Warwick", "Zac", "Urgot"],
      "true_damage"=> ["Ahri", "Corki", "Cho'Gath", "Fiora", "Irelia", "Garen", "Gangplank", "Twitch", "Master Yi", "Rek’Sai", "Vel’Koz", "Kog'Maw"],
      "high_dps"=> ["Ashe", "Azir", "Tryndamere", "Brand", "Tristana", "Caitlyn", "Cassiopeia", "Draven", "Ezreal", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Jax", "Jayce", "Jhin", "Jinx", "Kalista", "Katarina", "Kayle", "Kindred", "Kog'Maw", "LeBlanc", "Lucian", "Lux", "Master Yi", "Miss Fortune", "Rengar", "Riven", "Rumble", "Sivir", "Talon", "Twitch", "Varus", "Vayne", "Veigar", "Vel’Koz", "Viktor", "Vladimir", "Wukong", "Xerath", "Xin Zhao", "Zed", "Ziggs", "Zyra", "Yasuo"],
      "self_healing"=> ["Aatrox", "Alistar", "Bard", "Cho'Gath", "Dr. Mundo", "Elise", "Fiddlesticks", "Galio", "Gragas", "Hecarim", "Illaoi", "Irelia", "Karma", "Kayle", "Kindred", "Maokai", "Morgana", "Nami", "Nasus", "Nidalee", "Nocturne", "Nunu", "Olaf", "Rek’Sai", "Renekton", "Rengar", "Ryze", "Sona", "Swain", "Tahm Kench", "Taric", "Trundle", "Udyr", "Vladimir", "Volibear", "Warwick", "Xin Zhao", "Yorick", "Zac"],
      "high_burst"=> ["Ahri", "Akali", "Anivia", "Annie", "Azir", "Brand", "Cho'Gath", "Diana", "Draven", "Ekko", "Ezreal", "Fiddlesticks", "Fizz", "Gangplank", "Heimerdinger", "Jayce", "Jhin", "Kassadin", "Katarina", "Kennen", "Kha’Zix", "LeBlanc", "Lissandra", "Lux", "Master Yi", "Nidalee", "Nocturne", "Orianna", "Pantheon", "Rengar", "Riven", "Ryze", "Shaco", "Sona", "Syndra", "Talon", "Twisted Fate", "Varus", "Veigar", "Viktor", "Xerath", "Zed", "Ziggs", "Zyra", "Yasuo"],
      "healer"=> ["Alistar", "Bard", "Janna", "Kayle", "Nami", "Soraka", "Sona", "Nidalee" ],
      "aoe_cc" => ["Alistar", "Amumu", "Anivia", "Annie", "Ashe", "Bard", "Braum", "Cassiopeia", "Cho'Gath", "Gragas", "Galio", "Gankplank", "Karthus", "Kennen", "Leona", "Lissandra", "Lux", "Malphite", "Morgana", "Nami", "Nautilus", "Nunu", "Orianna", "Rumble", "Sejuani", "Sion", "Sona", "Taliyah", "Syndra", "Swain", "Varus", "Veigar", "Wukong", "Zac", "Zyra", "Yasuo"],
      "waveclear"=> ["Ahri", "Anivia", "Aurelion Sol", "Azir", "Brand", "Cassiopeia", "Caitlyn", "Cho'Gath", "Corki", "Fiddlesticks", "Galio", "Gragas", "Heimerdinger", "Janna", "Jayce", "Jinx", "Karma", "Karthus", "Katarina", "Lux", "Malzahar", "Morgana", "Nasus", "Orianna", "Rumble", "Swain", "Syndra", "Teemo", "Twisted Fate", "Varus", "Vel’Koz", "Xerath", "Zed", "Ziggs", "Zilean", "Zyra"],
      "preserving_ult"=>["Bard", "Kayle", "Kindred", "Zilean", 'Shen'],
      "poke"=>["Anivia", "Ashe", "Aurelion Sol", "Azir", "Brand", "Caitlyn", "Corki", "Ezreal", "Fiddlesticks", "Heimerdinger", "Gnar", "Jayce", "Jinx", "Karma", "Katarina", "Morgana", "Nidalee", "Orianna", "Sona", "Soraka", "Syndra", "Taliyah", "Teemo", "Varus", "Vel’Koz", "Viktor", "Xerath", "Zed", "Ziggs", "Zilean", "Zyra", 'Urgot'],
      "initiator"=>["Aatrox", "Ashe", "Alistar", "Amumu", "Annie", "Braum", "Blitzcrank", "Gragas", "Hecarim", "Jarvan IV", "Jax", "Kennen", "Lee Sin", "Leona", "Lissandra", "Malphite", "Morgana", "Nautilus", "Nocturne", "Olaf", "Pantheon", "Poppy", "Rammus", "Rek’Sai", "Rengar", "Sejuani", "Shen", "Shyvana", "Sion", "Singed", "Sona", "Swain", "Trundle", "Vi", "Volibear", "Wukong", "Warwick", "Zac"],
      "mobile"=>["Ahri", "Azir", "Tristana", "Caitlyn", "Corki", "Ekko", "Elise", "Ezreal", "Fiora", "Fizz", "Gnar", "Gragas", "Jarvan IV", "Kalista", "Kassadin", "Katarina", "Kennen", "Kha’Zix", "Kindred", "LeBlanc", "Lee Sin", "Lucian", "Quinn", "Rammus", "Riven", "Shyvana", "Udyr", "Vi", "Yasuo", "Zed"],
      "traps"=>["Caitlyn", "Heimerdinger", "Teemo", "Shaco", "Nidalee", "Jhin"],
      "displacement"=>["Anivia", "Aurelion Sol", "Corki", "Darius", "Blitzcrank", "Draven", "Gragas", "Hecarim", "Lee Sin", "Lulu", "Taliyah", "Orianna", "Poppy", "Syndra", "Quinn", "Thresh", "Singed", "Volibear", "Xin Zhao", "Zac", "Ziggs", "Urgot"],

      "good_scaling"=>['Akali', "Anivia", "Cassiopeia", "Irelia", "Jax", "Kayle", "Master Yi", "Ryze", "Olaf", "Swain", "Trundle", "Udyr", "Veigar", "Vladimir", "Xin Zhao"],
      "early_power"=>["Blitzcrank", "Draven", "Jayce", "Jhin", "Karma", "Miss Fortune", "Nidalee", "Pantheon", "Riven", "Shaco", "Twisted Fate", "Varus", "Volibear"],
      "terrain_generation"=>["Anivia", "Azir", "Trundle", "Jarvan IV", "Taliyah"],
      "stealth"=>["EvelyKn", "Kha’Zix", "Rengar", "Shaco", "Teemo", "Twitch", "Vayve", "Wukong"],

      "strong_level_6"=> ["Amumu", "Annie", "Anivia", "Brand", "Darius", "Ezreal", "Fiddlesticks", "Fizz", "Jax", "Karthus", "Katarina", "LeBlanc", "Lissandra", "Lux", "Malphite", "Malzahar", "Miss Fortune", "Mordekaiser", "Morgana", "Orianna", "Sejuani","Riven", "Sion", "Sona", "Swain", "Talon", "Taric", "Tryndamere", "Vel’Koz", "Vi", "Vladimir", "Warwick", "Yasuo", "Zed", "Zilean", "Zyra"]
    }

    champions["data"].each do |name, attributes|
      champion = Championbase.new()
      champion.name = attributes["name"]
      champion.title = attributes["title"]
      champion.champion_identifier = attributes["key"]
      champion.blurb = attributes["blurb"]

      champion.image = attributes["image"]["full"]
      champion.riot_tags = attributes["tags"]

      champion.stats = attributes["stats"]

      # Assign mulitple tags per champ
      champ_tags.each do |tag, champions|
        if champ_tags[tag].include?(champion.name)
          champion.other_tags.push(tag)
        end
      end
      

      if champion.save
        p "#{champion.name} saved!"
      else
        p "Champion already existed"
      end
    end
  end

end
