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


  # I need to categorize the tags a little better. I realize now that there are build-centric and playstyle-centric tags
  # much more than there are just static sets of tags that can be compared against one another.
  # I also need to order each tag array by precedence. Some champs just end up getting more tags, but that doesn't
  # mean all of the tags are equivalent in weight.


  champion_tags = {
    "Ahri"=>["true_damage", "high_burst", "waveclear", "mobile"],
    "Akali"=>["high_burst", "good_scaling"],
    "Alistar"=>["heavy_cc", "tanky", "self_healing", "healer", "aoe_cc", "initiator"],
    "Amumu"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
    "Anivia"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "good_scaling", "terrain_generation", "strong_level_6"],
    "Annie"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6"],
    "Ashe"=>["heavy_cc", "high_dps", "aoe_cc", "poke", "initiator"],
    "Aurelion Sol"=>["tanky", "waveclear", "poke", "displacement"],
    "Bard"=>["self_healing", "healer", "aoe_cc", "preserving_ult"],
    "Blitzcrank"=>["heavy_cc", "initiator", "displacement", "early_power"],
    "Brand"=>["high_dps", "high_burst", "waveclear", "poke", "strong_level_6"],
    "Braum"=>["heavy_cc", "tanky", "aoe_cc", "initiator"],
    "Caitlyn"=>["high_dps", "waveclear", "poke", "mobile", "traps"],
    "Cassiopeia"=>["heavy_cc", "high_dps", "aoe_cc", "waveclear", "good_scaling"],
    "Cho'Gath"=>["heavy_cc", "tanky", "true_damage", "self_healing", "high_burst", "aoe_cc", "waveclear"],
    "Corki"=>["true_damage", "waveclear", "poke", "mobile", "displacement"],
    "Diana"=>["high_burst"],
    "Draven"=>["high_dps", "high_burst", "displacement", "early_power"],
    "Dr. Mundo"=>["tanky", "self_healing"],
    "Ekko"=>["high_burst", "mobile"],
    "Elise"=>["heavy_cc", "self_healing", "mobile"],
    "Evelynn"=>["initiator", "mobile", "stealth"],
    "Ezreal"=>["high_dps", "high_burst", "poke", "mobile", "strong_level_6"],
    "Fiddlesticks"=>["heavy_cc", "high_dps", "self_healing", "high_burst", "waveclear", "poke", "strong_level_6"],
    "Fizz"=>["high_dps", "high_burst", "mobile", "strong_level_6"],
    "Galio"=>["heavy_cc", "tanky", "self_healing", "aoe_cc", "waveclear"],
    "Gangplank"=>["true_damage", "high_burst"],
    "Garen"=>["tanky", "true_damage"],
    "Gnar"=>["tanky", "poke", "mobile"],
    "Gragas"=>["heavy_cc", "tanky", "self_healing", "aoe_cc", "waveclear", "initiator", "mobile", "displacement"],
    "Graves"=>["mobile", "high_burst", "high_dps"],
    "Hecarim"=>["tanky", "self_healing", "initiator", "displacement"],
    "Illaoi"=>["tanky", "self_healing"],
    "Irelia"=>["tanky", "true_damage", "self_healing", "good_scaling"],
    "Janna"=>["heavy_cc", "healer", "waveclear"],
    "Jarvan IV"=>["initiator", "mobile", "terrain_generation"],
    "Jax"=>["high_dps", "initiator", "good_scaling", "strong_level_6"],
    "Jayce"=>["high_dps", "high_burst", "waveclear", "poke", "early_power"],
    "Jhin"=>["high_dps", "high_burst", "traps", "early_power"],
    "Jinx"=>["high_dps", "waveclear", "poke"],
    "Karma"=>["self_healing", "waveclear", "poke", "early_power"],
    "Karthus"=>["aoe_cc", "waveclear", "strong_level_6"],
    "Kassadin"=>["high_burst", "mobile"],
    "Katarina"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6"],
    "Kayle"=>["high_dps", "self_healing", "healer", "preserving_ult", "good_scaling"],
    "Kennen"=>["high_burst", "aoe_cc", "initiator", "mobile"],
    "Kha'Zix"=>["high_burst", "self_healing", "mobile", "stealth"],
    "Kindred"=>["high_dps", "self_healing", "preserving_ult", "mobile"],
    "Kog'Maw"=>["true_damage", "high_dps"],
    "LeBlanc"=>["high_dps", "high_burst", "mobile", "strong_level_6"],
    "Lee Sin"=>["initiator", "mobile", "displacement"],
    "Leona"=>["heavy_cc", "tanky", "aoe_cc", "initiator"],
    "Lissandra"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6"],
    "Lucian"=>["high_dps", "mobile"],
    "Lulu"=>["displacement"],
    "Lux"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "strong_level_6"],
    "Malzahar"=>["heavy_cc", "waveclear", "strong_level_6"],
    "Maokai"=>["heavy_cc", "tanky", "self_healing"],
    "Master Yi"=>["true_damage", "high_dps", "high_burst", "good_scaling"],
    "Miss Fortune"=>["high_dps", "early_power", "strong_level_6"],
    "Wukong"=>["high_dps", "aoe_cc", "initiator", "stealth"],
    "Mordekaiser"=>["strong_level_6"],
    "Morgana"=>["heavy_cc", "self_healing", "aoe_cc", "waveclear", "poke", "initiator", "strong_level_6"],
    "Nami"=>["heavy_cc", "self_healing", "healer", "aoe_cc"],
    "Nautilus"=>["heavy_cc", "tanky", "aoe_cc", "initiator"],
    "Nidalee"=>["self_healing", "high_burst", "healer", "poke", "traps", "early_power"],
    "Nocturne"=>["self_healing", "high_burst", "initiator"],
    "Nunu"=>["self_healing", "aoe_cc"],
    "Olaf"=>["tanky", "self_healing", "initiator", "good_scaling"],
    "Orianna"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "strong_level_6"],
    "Pantheon"=>["high_burst", "initiator", "early_power"],
    "Poppy"=>["heavy_cc", "initiator", "displacement"],
    "Rammus"=>["heavy_cc", "tanky", "initiator", "mobile"],
    "Rek'Sai"=>["tanky", "initiator", "mobile"],
    "Renekton"=>["tanky", "self_healing"],
    "Rengar"=>["high_dps", "self_healing", "high_burst", "initiator", "stealth"],
    "Riven"=>["heavy_cc", "high_dps", "high_burst", "mobile", "early_power", "strong_level_6"],
    "Rumble"=>["high_dps", "aoe_cc", "waveclear"],
    "Ryze"=>["heavy_cc", "self_healing", "high_burst", "good_scaling"],
    "Sejuani"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
    "Shen"=>["preserving_ult", "initiator"],
    "Shyvana"=>["tanky", "initiator", "mobile"],
    "Singed"=>["tanky", "initiator", "displacement"],
    "Sion"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
    "Sivir"=>["high_dps", "initiator", "high_dps"],
    "Skarner"=>["tanky", "mobile"],
    "Sona"=>["heavy_cc", "self_healing", "high_burst", "healer", "aoe_cc", "poke", "initiator", "strong_level_6"],
    "Soraka"=>["healer", "poke"],
    "Syndra"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement"],
    "Tahm Kench"=>["tanky", "self_healing"],
    "Taliyah"=>["aoe_cc", "poke", "displacement", "terrain_generation"],
    "Talon"=>["high_dps", "high_burst", "strong_level_6"],
    "Taric"=>["heavy_cc", "tanky", "self_healing", "strong_level_6"],
    "Teemo"=>["waveclear", "poke", "traps", "stealth"],
    "Thresh"=>["heavy_cc", "tanky", "displacement"],
    "Tristana"=>["high_dps", "mobile"],
    "Tryndamere"=>["high_dps", "strong_level_6"],
    "Twisted Fate"=>["heavy_cc", "high_burst", "waveclear", "early_power"],
    "Twitch"=>["true_damage", "high_dps", "stealth"],
    "Udyr"=>["tanky", "self_healing", "mobile", "good_scaling"],
    "Urgot"=>["tanky", "poke", "displacement"],
    "Varus"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "early_power"],
    "Vayne"=>["high_dps"],
    "Veigar"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "good_scaling"],
    "Vi"=>["heavy_cc", "tanky", "initiator", "mobile", "strong_level_6"],
    "Viktor"=>["high_dps", "high_burst", "poke"],
    "Vladimir"=>["tanky", "high_dps", "self_healing", "good_scaling", "strong_level_6"],
    "Volibear"=>["tanky", "self_healing", "initiator", "displacement", "early_power"],
    "Warwick"=>["heavy_cc", "tanky", "self_healing", "initiator", "strong_level_6"],
    "Xerath"=>["high_dps", "high_burst", "waveclear", "poke"],
    "Xin Zhao"=>["high_dps", "self_healing", "displacement", "good_scaling"],
    "Yasuo"=>["high_dps", "high_burst", "aoe_cc", "mobile", "strong_level_6"],
    "Aatrox"=>["self_healing", "initiator"],
    "Azir"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "terrain_generation"],
    "Darius"=>["tanky", "displacement", "strong_level_6"],
    "Zac"=>["tanky", "self_healing", "aoe_cc", "initiator", "displacement"],
    "Zed"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6"],
    "Ziggs"=>["high_dps", "high_burst", "waveclear", "poke", "displacement"],
    "Zilean"=>["waveclear", "preserving_ult", "poke", "strong_level_6"],
    "Zyra"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "strong_level_6"],
    "Fiora"=>["true_damage", "high_dps", "mobile"],
    "Heimerdinger"=>["high_dps", "high_burst", "waveclear", "poke", "traps"],
    "Kalista"=>["high_dps", "mobile"],
    "Kled"=>["mobile", "initiator", "high_burst"],
    "Malphite"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
    "Nasus"=>["tanky", "self_healing", "waveclear"],
    "Quinn"=>["mobile", "displacement"],
    "Shaco"=>["high_burst", "traps", "early_power", "stealth"],
    "Swain"=>["tanky", "self_healing", "aoe_cc", "waveclear", "initiator", "good_scaling", "strong_level_6"],
    "Trundle"=>["self_healing", "initiator", "good_scaling", "terrain_generation"],
    "Vel'Koz"=>["poke", "high_dps", "good_scaling"],
    "Yorick"=>["self_healing"],
  }

  def self.seed_championbase_list
    request = "http://ddragon.leagueoflegends.com/cdn/6.16.2/data/en_US/champion.json"
    response = HTTParty.get(request)
    champions = response.parsed_response

    # Some champs with apostrophes are not populating correctly.
    champ_tags = [
      # Can Build Against
      "heavy_cc",
      "tanky" ,
      "true_damage",
      "high_dps",
      "self_healing",
      "high_burst",
      "healer",
      "aoe_cc" ,
      "preserving_ult",
      "poke",
      "stealth",

      # Playstyle Dependent
      "waveclear",
      "initiator",
      "mobile",
      "traps",
      "displacement",
      "good_scaling",
      "early_power",
      "terrain_generation",
      "strong_level_6",
    ]

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
