class Championbase < ActiveRecord::Base
  serialize :stats

  has_many :champions
  validates :champion_identifier, uniqueness: true

  has_many :builds
  has_many :popular_items, through: :builds, source: :item

  require 'open-uri'

  def self.scrape_for_champion_stats

    bases = Championbase.all
    bases.each do |champ|
      # Metasrc uses champion names formated like aurelionsol or khazix. All lower case, no spaces, hyphens, apostrophes or periods.
      formatted_champ_name = champ.name.gsub(/[. ']/, "").downcase

      doc = Nokogiri::HTML(open("http://www.metasrc.com/na/aram/champion/#{formatted_champ_name}"))

      # Finds all popular items on the given champion's page and associates them to the popular_items attribute on the current Championbase.
      champ.popular_items = doc.css('div#items ul li img').map{ |e| Item.where(item_identifier: e["id"].split('-')[1]).take }

      # Pulling relevant stats out of the document...
      champ.tier = doc.css('div#container div#stats table tr td')[0].text
      champ.score = doc.css('div#container div#stats table tr td')[1].text
      champ.win_rate = doc.css('div#container div#stats table tr td')[2].text.gsub('%', '').to_f
      champ.pick_rate = doc.css('div#container div#stats table tr td')[3].text.gsub('%', '').to_f
      champ.KDA = doc.css('div#container div#stats table tr td')[4].text.to_f

      if champ.save
        ap champ
      else
        p "Scrape for #{champ.name} failed."
        return {error: "Champion scrape build failed."}
      end
    end 
  end


  def self.seed_championbase_list
    request = "http://ddragon.leagueoflegends.com/cdn/6.16.2/data/en_US/champion.json"
    response = HTTParty.get(request)
    champions = response.parsed_response

    # If the champion_tags look like a shitshow, that's because they are. This will all eventually be pulled out into a CSV or JSON file and
    # stored with a timestamp in the header or something. This is just an ititial tag setup so I can worry about designing the 
    # analytics while having some kind of basic tagging system in place.

    champion_tags = {
      "Ahri"=>["true_damage", "high_burst", "waveclear", "mobile", "magic_damage", "squishy_mage"],
      "Akali"=>["high_burst", "good_scaling", "hybrid", "squishy_hybrid"],
      "Alistar"=>["heavy_cc", "tank", "self_healing", "healer", "aoe_cc", "initiator", "cooldowns"],
      "Amumu"=>["heavy_cc", "tank", "aoe_cc", "initiator", "strong_level_6", "magic_damage"],
      "Anivia"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "good_scaling", "terrain_generation", "strong_level_6", "magic_damage", "squishy_mage"],
      "Annie"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6", "magic_damage", "squishy_mage"],
      "Ashe"=>["heavy_cc", "high_dps", "aoe_cc", "poke", "initiator", "physical_damage", "squishy_physical"],
      "Aurelion Sol"=>["magic_bruiser", "waveclear", "poke", "displacement", "magic_damage", "slows"],
      "Bard"=>["self_healing", "healer", "aoe_cc", "preserving_ult", "cooldowns", "squishy_support"],
      "Blitzcrank"=>["heavy_cc", "initiator", "displacement", "early_power", "cooldowns", "tank"],
      "Brand"=>["high_dps", "high_burst", "waveclear", "poke", "strong_level_6", "magic_damage", "squishy_mage"],
      "Braum"=>["heavy_cc", "tank", "aoe_cc", "initiator", "slows"],
      "Caitlyn"=>["high_dps", "waveclear", "poke", "mobile", "traps", "physical_damage", "squishy_physical"],
      "Cassiopeia"=>["heavy_cc", "high_dps", "aoe_cc", "waveclear", "good_scaling", "magic_damage", "slows", "roots", "beefy_mage"],
      "Cho'Gath"=>["heavy_cc", "magic_bruiser", "true_damage", "self_healing", "high_burst", "aoe_cc", "waveclear", "slows", "magic_damage"],
      "Corki"=>["true_damage", "waveclear", "poke", "mobile", "displacement", "hybrid", "squishy_hybrid"],
      "Diana"=>["high_burst", "magic_damage", "cooldowns", "magic_bruiser"],
      "Draven"=>["high_dps", "high_burst", "displacement", "early_power", "physical_damage", "squishy_physical"],
      "Dr. Mundo"=>["tank", "self_healing", "slows"],
      "Ekko"=>["high_burst", "mobile", "magic_damage", "slows", "magic_bruiser"],
      "Elise"=>["heavy_cc", "self_healing", "mobile", "magic_damage", "magic_bruiser"],
      "Evelynn"=>["initiator", "mobile", "stealth", "hybrid", "magic_bruiser"],
      "Ezreal"=>["high_dps", "high_burst", "poke", "mobile", "strong_level_6", "physical_damage", "hybrid", "squishy_hybrid"],
      "Fiddlesticks"=>["heavy_cc", "high_dps", "self_healing", "high_burst", "waveclear", "poke", "strong_level_6", "magic_damage", "cooldowns", "squishy_mage"],
      "Fizz"=>["high_dps", "high_burst", "mobile", "strong_level_6", "cooldowns", "magic_damage", "magic_bruiser"],
      "Galio"=>["heavy_cc", "tank", "self_healing", "aoe_cc", "waveclear", "slows", "roots"],
      "Gangplank"=>["true_damage", "high_burst", "physical_damage", "squishy_physical"],
      "Garen"=>["tank", "true_damage", "physical_damage"],
      "Gnar"=>["tank", "poke", "mobile", "physical_damage"],
      "Gragas"=>["heavy_cc", "magic_bruiser", "self_healing", "aoe_cc", "waveclear", "initiator", "mobile", "displacement", "magic_damage"],
      "Graves"=>["mobile", "high_burst", "high_dps", "physical_damage", "squishy_physical"],
      "Hecarim"=>["physical_bruiser", "self_healing", "initiator", "displacement"],
      "Illaoi"=>["physical_bruiser", "self_healing", "physical_damage"],
      "Irelia"=>["physical_bruiser", "true_damage", "self_healing", "good_scaling", "physical_damage"],
      "Janna"=>["heavy_cc", "healer", "waveclear", "magic_damage", "squishy_support"],
      "Jarvan IV"=>["initiator", "mobile", "terrain_generation", "physical_damage", "tank"],
      "Jax"=>["high_dps", "initiator", "good_scaling", "strong_level_6", "hybrid", "squishy_hybrid"],
      "Jayce"=>["high_dps", "high_burst", "waveclear", "poke", "early_power", "squishy_physical", "physical_damage"],
      "Jhin"=>["high_dps", "high_burst", "traps", "early_power", "squishy_physical", "physical_damage"],
      "Jinx"=>["high_dps", "waveclear", "poke", "physical_damage", "squishy_physical"],
      "Karma"=>["self_healing", "waveclear", "poke", "early_power", "magic_damage", "squishy_mage"],
      "Karthus"=>["aoe_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Kassadin"=>["high_burst", "mobile", "magic_damage", "squishy_mage"],
      "Katarina"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6", "magic_damage", "squishy_mage"],
      "Kayle"=>["high_dps", "self_healing", "healer", "preserving_ult", "good_scaling", "hybrid", "squishy_hybrid"],
      "Kennen"=>["high_burst", "aoe_cc", "initiator", "mobile", "magic_damage", "beefy_mage"],
      "Kha'Zix"=>["high_burst", "self_healing", "mobile", "stealth", "physical_damage", "physical_bruiser"],
      "Kindred"=>["high_dps", "self_healing", "preserving_ult", "mobile", "physical_damage", "squishy_physical"],
      "Kog'Maw"=>["true_damage", "high_dps", "physical_damage", "squishy_physical"],
      "LeBlanc"=>["high_dps", "high_burst", "mobile", "strong_level_6", "magic_damage", "squishy_mage"],
      "Lee Sin"=>["initiator", "mobile", "displacement", "physical_damage", "physical_bruiser"],
      "Leona"=>["heavy_cc", "tank", "aoe_cc", "initiator"],
      "Lissandra"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6", "magic_damage", "beefy_mage"],
      "Lucian"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Lulu"=>["displacement", "waveclear", "magic_damage", "squishy_support"],
      "Lux"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Malzahar"=>["heavy_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Maokai"=>["heavy_cc", "tank", "self_healing", "magic_damage"],
      "Master Yi"=>["true_damage", "high_dps", "high_burst", "good_scaling", "physical_damage", "squishy_physical"],
      "Miss Fortune"=>["high_dps", "early_power", "strong_level_6", "physical_damage", "squishy_physical"],
      "Wukong"=>["high_dps", "aoe_cc", "initiator", "stealth", "physical_damage", "physical_bruiser"],
      "Mordekaiser"=>["strong_level_6", "hybird", "squishy_hybrid"],
      "Morgana"=>["heavy_cc", "self_healing", "aoe_cc", "waveclear", "poke", "initiator", "strong_level_6", "magic_damage", "beefy_mage"],
      "Nami"=>["heavy_cc", "self_healing", "healer", "aoe_cc", "squishy_support"],
      "Nautilus"=>["heavy_cc", "tank", "aoe_cc", "initiator"],
      "Nidalee"=>["self_healing", "high_burst", "healer", "poke", "traps", "early_power", "magic_damage", "squishy_mage"],
      "Nocturne"=>["self_healing", "high_burst", "initiator", "physical_damage", "physical_bruiser"],
      "Nunu"=>["self_healing", "aoe_cc", "magic_damage", "beefy_mage"],
      "Olaf"=>["tank", "self_healing", "initiator", "good_scaling"],
      "Orianna"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "strong_level_6", "magic_damage", "squishy_mage"],
      "Pantheon"=>["high_burst", "initiator", "early_power", "physical_damage", "physical_bruiser"],
      "Poppy"=>["heavy_cc", "initiator", "displacement", "tank"],
      "Rammus"=>["heavy_cc", "tank", "initiator", "mobile"],
      "Rek'Sai"=>["tank", "initiator", "mobile"],
      "Renekton"=>["physical_bruiser", "self_healing", "physical_damage"],
      "Rengar"=>["high_dps", "self_healing", "high_burst", "initiator", "stealth", "physical_damage", "physical_bruiser"],
      "Riven"=>["heavy_cc", "high_dps", "high_burst", "mobile", "early_power", "strong_level_6", "physical_bruiser"],
      "Rumble"=>["high_dps", "aoe_cc", "waveclear", "magic_damage", "squishy_mage"],
      "Ryze"=>["heavy_cc", "self_healing", "high_burst", "good_scaling", "beefy_mage", "tank"],
      "Sejuani"=>["heavy_cc", "tank", "aoe_cc", "initiator", "strong_level_6"],
      "Shen"=>["preserving_ult", "initiator", "tank"],
      "Shyvana"=>["tank", "initiator", "mobile", "physical_bruiser"],
      "Singed"=>["tank", "initiator", "displacement", "magic_damage"],
      "Sion"=>["heavy_cc", "tank", "aoe_cc", "initiator", "strong_level_6"],
      "Sivir"=>["high_dps", "initiator", "physical_damage", "squishy_physical"],
      "Skarner"=>["tank", "mobile", "displacement"],
      "Sona"=>["heavy_cc", "self_healing", "high_burst", "healer", "aoe_cc", "poke", "initiator", "strong_level_6", "magic_damage", "squishy_support"],
      "Soraka"=>["healer", "poke", "squishy_support"],
      "Syndra"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "magic_damage", "squishy_mage"],
      "Tahm Kench"=>["tank", "self_healing"],
      "Taliyah"=>["aoe_cc", "poke", "displacement", "terrain_generation", "magic_damage", "squishy_mage"],
      "Talon"=>["high_dps", "high_burst", "strong_level_6", "physical_damage", "squishy_physical"],
      "Taric"=>["heavy_cc", "tank", "self_healing", "strong_level_6"],
      "Teemo"=>["waveclear", "poke", "traps", "stealth", "magic_damage", "squishy_mage"],
      "Thresh"=>["heavy_cc", "tank", "displacement", "tank"],
      "Tristana"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Tryndamere"=>["high_dps", "strong_level_6", "preserving_ult", "squishy_physical"],
      "Twisted Fate"=>["heavy_cc", "high_burst", "waveclear", "early_power", "magic_damage", "squishy_mage"],
      "Twitch"=>["true_damage", "high_dps", "stealth", "physical_damage", "squishy_physical"],
      "Udyr"=>["tank", "self_healing", "mobile", "good_scaling", "physical_bruiser"],
      "Urgot"=>["tank", "poke", "displacement", "physical_bruiser"],
      "Varus"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "early_power", "physical_damage", "squishy_physical"],
      "Vayne"=>["high_dps", "physical_damage", "squishy_physical", "stealth"],
      "Veigar"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "good_scaling", "magic_damage", "squishy_mage"],
      "Vi"=>["heavy_cc", "tank", "initiator", "mobile", "strong_level_6", "physical_damage"],
      "Viktor"=>["high_dps", "high_burst", "poke", "magic_damage", "squishy_mage"],
      "Vladimir"=>["beefy_mage", "high_dps", "self_healing", "good_scaling", "strong_level_6", "magic_damage"],
      "Volibear"=>["tank", "self_healing", "initiator", "displacement", "early_power"],
      "Warwick"=>["heavy_cc", "tank", "self_healing", "initiator", "strong_level_6"],
      "Xerath"=>["high_dps", "high_burst", "waveclear", "poke", "magic_damage", "squishy_mage"],
      "Xin Zhao"=>["high_dps", "self_healing", "displacement", "good_scaling", "physical_damage", "tank"],
      "Yasuo"=>["high_dps", "high_burst", "aoe_cc", "mobile", "strong_level_6", "physical_damage", "squishy_physical"],
      "Aatrox"=>["self_healing", "initiator", "physical_bruiser"],
      "Azir"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "terrain_generation", "magic_damage", "squishy_mage"],
      "Darius"=>["physical_bruiser", "displacement", "strong_level_6", "physical_damage"],
      "Zac"=>["tank", "self_healing", "aoe_cc", "initiator", "displacement"],
      "Zed"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6", "physical_damage", "squishy_physical"],
      "Ziggs"=>["high_dps", "high_burst", "waveclear", "poke", "displacement", "magic_damage", "squishy_mage"],
      "Zilean"=>["waveclear", "preserving_ult", "poke", "strong_level_6", "magic_damage", "squishy_mage"],
      "Zyra"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "strong_level_6", "magic_damage", "squishy_mage", "slows", "roots"],
      "Fiora"=>["true_damage", "high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Heimerdinger"=>["high_dps", "high_burst", "waveclear", "poke", "traps", "magic_damage", "squishy_mage"],
      "Kalista"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Kled"=>["mobile", "initiator", "high_burst", "physical_bruiser"],
      "Malphite"=>["heavy_cc", "tank", "aoe_cc", "initiator", "strong_level_6"],
      "Nasus"=>["tank", "self_healing", "waveclear", "magic_damage"],
      "Quinn"=>["mobile", "displacement", "physical_damage", "squishy_physical"],
      "Shaco"=>["high_burst", "traps", "early_power", "stealth", "hybrid", "squishy_mage"],
      "Swain"=>["beefy_mage", "self_healing", "aoe_cc", "waveclear", "initiator", "good_scaling", "strong_level_6", "magic_damage"],
      "Trundle"=>["self_healing", "initiator", "good_scaling", "terrain_generation", "physical_damage", "tank"],
      "Vel'Koz"=>["poke", "high_dps", "good_scaling", "magic_damage", "squishy_mage"],
      "Yorick"=>["self_healing", "physical_damage", "physical_bruiser"],
    }    

    # Some champs with apostrophes are not populating correctly.
    tag_type_distinctions = {

      # These tags should only exist once on a champion and correspond to what could be considered their primary strength on ARAM.
      :primary_tags => 
      [
        
        "tank", # EX: Sion, Rammus
        "physical_bruiser", # EX: Renekton, Riven
        "magic_bruiser", # EX: Diana, Evelynn
        "squishy_physical", # EX: Caitlyn, Talon
        "squishy_mage", # EX: Syndra, Ahri
        "squishy_support", # EX: Sona, Bard
        "squishy_hybrid", # EX: Kayle
        "beefy_mage", # EX: Nunu, Swain
        "hybrid" # EX: Jax
      ],

      # This set has more to do with item strength/weakness augmentation. These are taken in to account more lightly than primary_tags
      # but still play a key role in the automated decision making process and will probably show up on the front-end as well.
      :build_tags => 
      [ 
        "heavy_cc", # EX: Alistar, Leona
        "true_damage", # EX: Cho'gath, Irelia
        "high_dps", # EX: ADC, Kayle
        "self_healing", # EX: Garen, Dr. Mundo, Hecarim
        "high_burst", # EX: Ahri, Syndra
        "healer", # EX; Sona, Soraka
        "aoe_cc", # EX: Amumu, Galio
        "preserving_ult", # EX: Kayle, Tryndamere
        "poke", # EX: Vel'koz, Nidalee
        "stealth", # EX: Teemo, Twitch
        "physical_damage", # EX: squishy_physical, physical_bruiser champs
        "magic_damage", # EX: squishy_mage, beefy_mage, magic_bruiser
        "cooldowns", # EX: Talon, Syndra, Heimerdinger
        "roots", # EX: Zyra, Ryze
        "slows" # EX: Ashe, Evelynn
      ],

      # These are 'preferred' playstyle archetype tags. While there are counters to be made against these, it is not within
      # reasonable feature scope to account for everyone's playstyles on the other team until a LOT more data is collected and ELO
      # stats come in to play.
      :playstyle_tags => 
      [
        "waveclear",
        "initiator",
        "mobile",
        "traps",
        "displacement",
        "good_scaling",
        "early_power",
        "terrain_generation",
        "strong_level_6",
        "skillshots",
        "disengage",
        "siege"      
      ]
    }

    champions["data"].each do |name, attributes|
      champion = Championbase.new
      champion.name = attributes["name"]
      champion.title = attributes["title"]
      champion.champion_identifier = attributes["key"]
      champion.blurb = attributes["blurb"]

      champion.image = attributes["image"]["full"]
      champion.riot_tags = attributes["tags"]

      champion.stats = attributes["stats"]

      # Assign tags based on the key associated with it...
      champion_tags[attributes["name"]].each do |tag|
        if tag_type_distinctions[:build_tags].include? tag 
          champion.build_tags << tag 
        elsif tag_type_distinctions[:playstyle_tags].include? tag 
          champion.playstyle_tags << tag
        elsif tag_type_distinctions[:primary_tags].include? tag
          champion.primary_tag = tag
        else
          p "Could not assign #{tag} to #{champion.name}."
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
