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
      # Metasrc uses champion names formated like aurelionsol or khazix. All lower case, no spaces, no hyphens or apostrophes, no periods.
      formatted_champ_name = champ.name.gsub(/[. ']/, "").downcase

      doc = Nokogiri::HTML(open("http://www.metasrc.com/na/aram/champion/#{formatted_champ_name}"))

      champ.popular_items = doc.css('div#items ul li img').map{ |e| Item.where(item_identifier: e["id"].split('-')[1]).take }

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

  def self.seed_championbase_list
    request = "http://ddragon.leagueoflegends.com/cdn/6.16.2/data/en_US/champion.json"
    response = HTTParty.get(request)
    champions = response.parsed_response

        # "physical_damage",
        # "magic_damage",
        # "cooldowns",
        # "roots",
        # "slows",
        # "squishy"
        # hybrid

    champion_tags = {
      "Ahri"=>["true_damage", "high_burst", "waveclear", "mobile", "magic_damage", "squishy_mage"],
      "Akali"=>["high_burst", "good_scaling", "hybrid", "squishy_hybrid"],
      "Alistar"=>["heavy_cc", "tanky", "self_healing", "healer", "aoe_cc", "initiator", "cooldowns"],
      "Amumu"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6", "magic_damage"],
      "Anivia"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "good_scaling", "terrain_generation", "strong_level_6", "magic_damage", "squishy_mage"],
      "Annie"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6", "magic_damage", "squishy_mage"],
      "Ashe"=>["heavy_cc", "high_dps", "aoe_cc", "poke", "initiator", "physical_damage", "squishy_physical"],
      "Aurelion Sol"=>["tanky", "waveclear", "poke", "displacement", "magic_damage", "slows"],
      "Bard"=>["self_healing", "healer", "aoe_cc", "preserving_ult", "cooldowns", "squishy_support"],
      "Blitzcrank"=>["heavy_cc", "initiator", "displacement", "early_power", "cooldowns", "tanky"],
      "Brand"=>["high_dps", "high_burst", "waveclear", "poke", "strong_level_6", "magic_damage", "squishy_mage"],
      "Braum"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "slows"],
      "Caitlyn"=>["high_dps", "waveclear", "poke", "mobile", "traps", "physical_damage", "squishy_physical"],
      "Cassiopeia"=>["heavy_cc", "high_dps", "aoe_cc", "waveclear", "good_scaling", "magic_damage", "slows", "roots", "squishy_mage"],
      "Cho'Gath"=>["heavy_cc", "tanky", "true_damage", "self_healing", "high_burst", "aoe_cc", "waveclear", "slows", "magic_damage"],
      "Corki"=>["true_damage", "waveclear", "poke", "mobile", "displacement", "hybrid", "squishy_hybrid"],
      "Diana"=>["high_burst", "magic_damage", "cooldowns", "squishy_mage"],
      "Draven"=>["high_dps", "high_burst", "displacement", "early_power", "physical_damage", "squishy_physical"],
      "Dr. Mundo"=>["tanky", "self_healing", "slows"],
      "Ekko"=>["high_burst", "mobile", "magic_damage", "slows", "squishy_mage"],
      "Elise"=>["heavy_cc", "self_healing", "mobile", "magic_damage", "tanky"],
      "Evelynn"=>["initiator", "mobile", "stealth", "hybrid", "tanky"],
      "Ezreal"=>["high_dps", "high_burst", "poke", "mobile", "strong_level_6", "physical_damage", "hybrid", "squishy_hybrid"],
      "Fiddlesticks"=>["heavy_cc", "high_dps", "self_healing", "high_burst", "waveclear", "poke", "strong_level_6", "magic_damage", "cooldowns", "squishy_mage"],
      "Fizz"=>["high_dps", "high_burst", "mobile", "strong_level_6", "cooldowns", "magic_damage", "squishy_mage"],
      "Galio"=>["heavy_cc", "tanky", "self_healing", "aoe_cc", "waveclear", "slows", "roots"],
      "Gangplank"=>["true_damage", "high_burst", "physical_damage", "squishy_physical"],
      "Garen"=>["tanky", "true_damage", "physical_damage"],
      "Gnar"=>["tanky", "poke", "mobile", "physical_damage"],
      "Gragas"=>["heavy_cc", "tanky", "self_healing", "aoe_cc", "waveclear", "initiator", "mobile", "displacement", "magic_damage"],
      "Graves"=>["mobile", "high_burst", "high_dps", "physical_damage", "squishy_physical"],
      "Hecarim"=>["tanky", "self_healing", "initiator", "displacement"],
      "Illaoi"=>["tanky", "self_healing", "physical_damage"],
      "Irelia"=>["tanky", "true_damage", "self_healing", "good_scaling", "physical_damage"],
      "Janna"=>["heavy_cc", "healer", "waveclear", "magic_damage", "squishy_support"],
      "Jarvan IV"=>["initiator", "mobile", "terrain_generation", "physical_damage", "tanky"],
      "Jax"=>["high_dps", "initiator", "good_scaling", "strong_level_6", "hybrid", "squishy_hybrid"],
      "Jayce"=>["high_dps", "high_burst", "waveclear", "poke", "early_power", "squishy_physical", "physical_damage"],
      "Jhin"=>["high_dps", "high_burst", "traps", "early_power", "squishy_physical", "physical_damage"],
      "Jinx"=>["high_dps", "waveclear", "poke", "physical_damage", "squishy_physical"],
      "Karma"=>["self_healing", "waveclear", "poke", "early_power", "magic_damage", "squishy_mage"],
      "Karthus"=>["aoe_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Kassadin"=>["high_burst", "mobile", "magic_damage", "squishy_mage"],
      "Katarina"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6", "magic_damage", "squishy_mage"],
      "Kayle"=>["high_dps", "self_healing", "healer", "preserving_ult", "good_scaling", "hybrid", "squishy_hybrid"],
      "Kennen"=>["high_burst", "aoe_cc", "initiator", "mobile", "magic_damage", "squishy_mage"],
      "Kha'Zix"=>["high_burst", "self_healing", "mobile", "stealth", "physical_damage", "squishy_physical"],
      "Kindred"=>["high_dps", "self_healing", "preserving_ult", "mobile", "physical_damage", "squishy_physical"],
      "Kog'Maw"=>["true_damage", "high_dps", "physical_damage", "squishy_physical"],
      "LeBlanc"=>["high_dps", "high_burst", "mobile", "strong_level_6", "magic_damage", "squishy_mage"],
      "Lee Sin"=>["initiator", "mobile", "displacement", "physical_damage", "tanky"],
      "Leona"=>["heavy_cc", "tanky", "aoe_cc", "initiator"],
      "Lissandra"=>["heavy_cc", "high_burst", "aoe_cc", "initiator", "strong_level_6", "magic_damage", "squishy_mage"],
      "Lucian"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Lulu"=>["displacement", "waveclear", "magic_damage", "squishy_support"],
      "Lux"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Malzahar"=>["heavy_cc", "waveclear", "strong_level_6", "magic_damage", "squishy_mage"],
      "Maokai"=>["heavy_cc", "tanky", "self_healing", "magic_damage"],
      "Master Yi"=>["true_damage", "high_dps", "high_burst", "good_scaling", "physical_damage", "squishy_physical"],
      "Miss Fortune"=>["high_dps", "early_power", "strong_level_6", "physical_damage", "squishy_physical"],
      "Wukong"=>["high_dps", "aoe_cc", "initiator", "stealth", "physical_damage", "tanky"],
      "Mordekaiser"=>["strong_level_6", "hybird", "squishy_hybrid"],
      "Morgana"=>["heavy_cc", "self_healing", "aoe_cc", "waveclear", "poke", "initiator", "strong_level_6", "magic_damage", "squishy_mage"],
      "Nami"=>["heavy_cc", "self_healing", "healer", "aoe_cc", "squishy_support"],
      "Nautilus"=>["heavy_cc", "tanky", "aoe_cc", "initiator"],
      "Nidalee"=>["self_healing", "high_burst", "healer", "poke", "traps", "early_power", "magic_damage", "squishy_mage"],
      "Nocturne"=>["self_healing", "high_burst", "initiator", "physical_damage", "tanky"],
      "Nunu"=>["self_healing", "aoe_cc", "magic_damage", "squishy_mage"],
      "Olaf"=>["tanky", "self_healing", "initiator", "good_scaling"],
      "Orianna"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "strong_level_6", "magic_damage", "squishy_mage"],
      "Pantheon"=>["high_burst", "initiator", "early_power", "physical_damage", "tanky"],
      "Poppy"=>["heavy_cc", "initiator", "displacement", "tanky"],
      "Rammus"=>["heavy_cc", "tanky", "initiator", "mobile"],
      "Rek'Sai"=>["tanky", "initiator", "mobile"],
      "Renekton"=>["tanky", "self_healing", "physical_damage"],
      "Rengar"=>["high_dps", "self_healing", "high_burst", "initiator", "stealth", "physical_damage", "squishy_physical"],
      "Riven"=>["heavy_cc", "high_dps", "high_burst", "mobile", "early_power", "strong_level_6", "squishy_physical"],
      "Rumble"=>["high_dps", "aoe_cc", "waveclear", "magic_damage", "squishy_mage"],
      "Ryze"=>["heavy_cc", "self_healing", "high_burst", "good_scaling", "magic_damage", "tanky"],
      "Sejuani"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
      "Shen"=>["preserving_ult", "initiator", "tanky"],
      "Shyvana"=>["tanky", "initiator", "mobile", "physical_damage"],
      "Singed"=>["tanky", "initiator", "displacement", "magic_damage"],
      "Sion"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
      "Sivir"=>["high_dps", "initiator", "physical_damage", "squishy_physical"],
      "Skarner"=>["tanky", "mobile", "displacement"],
      "Sona"=>["heavy_cc", "self_healing", "high_burst", "healer", "aoe_cc", "poke", "initiator", "strong_level_6", "magic_damage", "squishy_support"],
      "Soraka"=>["healer", "poke", "squishy_support"],
      "Syndra"=>["heavy_cc", "high_burst", "aoe_cc", "waveclear", "poke", "displacement", "magic_damage", "squishy_mage"],
      "Tahm Kench"=>["tanky", "self_healing"],
      "Taliyah"=>["aoe_cc", "poke", "displacement", "terrain_generation", "magic_damage", "squishy_mage"],
      "Talon"=>["high_dps", "high_burst", "strong_level_6", "physical_damage", "squishy_physical"],
      "Taric"=>["heavy_cc", "tanky", "self_healing", "strong_level_6"],
      "Teemo"=>["waveclear", "poke", "traps", "stealth", "magic_damage", "squishy_mage"],
      "Thresh"=>["heavy_cc", "tanky", "displacement", "tanky"],
      "Tristana"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Tryndamere"=>["high_dps", "strong_level_6", "preserving_ult", "squishy_physical"],
      "Twisted Fate"=>["heavy_cc", "high_burst", "waveclear", "early_power", "magic_damage", "squishy_mage"],
      "Twitch"=>["true_damage", "high_dps", "stealth", "physical_damage", "squishy_physical"],
      "Udyr"=>["tanky", "self_healing", "mobile", "good_scaling", "hybrid"],
      "Urgot"=>["tanky", "poke", "displacement", "physical_damage"],
      "Varus"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "early_power", "physical_damage", "squishy_physical"],
      "Vayne"=>["high_dps", "physical_damage", "squishy_physical", "stealth"],
      "Veigar"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "good_scaling", "magic_damage", "squishy_mage"],
      "Vi"=>["heavy_cc", "tanky", "initiator", "mobile", "strong_level_6", "physical_damage"],
      "Viktor"=>["high_dps", "high_burst", "poke", "magic_damage", "squishy_mage"],
      "Vladimir"=>["tanky", "high_dps", "self_healing", "good_scaling", "strong_level_6", "magic_damage"],
      "Volibear"=>["tanky", "self_healing", "initiator", "displacement", "early_power"],
      "Warwick"=>["heavy_cc", "tanky", "self_healing", "initiator", "strong_level_6"],
      "Xerath"=>["high_dps", "high_burst", "waveclear", "poke", "magic_damage", "squishy_mage"],
      "Xin Zhao"=>["high_dps", "self_healing", "displacement", "good_scaling", "physical_damage", "tanky"],
      "Yasuo"=>["high_dps", "high_burst", "aoe_cc", "mobile", "strong_level_6", "physical_damage", "squishy_physical"],
      "Aatrox"=>["self_healing", "initiator", "tanky"],
      "Azir"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "terrain_generation", "magic_damage", "squishy_mage"],
      "Darius"=>["tanky", "displacement", "strong_level_6", "physical_damage"],
      "Zac"=>["tanky", "self_healing", "aoe_cc", "initiator", "displacement"],
      "Zed"=>["high_dps", "high_burst", "waveclear", "poke", "mobile", "strong_level_6", "physical_damage", "squishy_physical"],
      "Ziggs"=>["high_dps", "high_burst", "waveclear", "poke", "displacement", "magic_damage", "squishy_mage"],
      "Zilean"=>["waveclear", "preserving_ult", "poke", "strong_level_6", "magic_damage", "squishy_mage"],
      "Zyra"=>["heavy_cc", "high_dps", "high_burst", "aoe_cc", "waveclear", "poke", "strong_level_6", "magic_damage", "squishy_mage", "slows", "roots"],
      "Fiora"=>["true_damage", "high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Heimerdinger"=>["high_dps", "high_burst", "waveclear", "poke", "traps", "magic_damage", "squishy_mage"],
      "Kalista"=>["high_dps", "mobile", "physical_damage", "squishy_physical"],
      "Kled"=>["mobile", "initiator", "high_burst", "tanky"],
      "Malphite"=>["heavy_cc", "tanky", "aoe_cc", "initiator", "strong_level_6"],
      "Nasus"=>["tanky", "self_healing", "waveclear", "magic_damage"],
      "Quinn"=>["mobile", "displacement", "physical_damage", "squishy_physical"],
      "Shaco"=>["high_burst", "traps", "early_power", "stealth", "hybrid", "squishy_mage"],
      "Swain"=>["tanky", "self_healing", "aoe_cc", "waveclear", "initiator", "good_scaling", "strong_level_6", "magic_damage"],
      "Trundle"=>["self_healing", "initiator", "good_scaling", "terrain_generation", "physical_damage", "tanky"],
      "Vel'Koz"=>["poke", "high_dps", "good_scaling", "magic_damage", "squishy_mage"],
      "Yorick"=>["self_healing", "physical_damage", "tanky"],
    }    

    # Some champs with apostrophes are not populating correctly.
    tag_type_distinctions = {

      :stat_emphasis_tags => [
        # Nothing yet. Will line up with tags present on items.
      ],

      :build_tags => 
      [ 
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
        # New Additions:
        "physical_damage",
        "magic_damage",
        "cooldowns",
        "roots",
        "slows",
        "squishy_mage",
        "squishy_physical",
        "squishy_support",
        "hybrid"
      ],

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
        # New Additions:
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

      champion_tags[attributes["name"]].each do |tag|
        if tag_type_distinctions[:build_tags].include? tag 
          champion.build_tags << tag 
        elsif tag_type_distinctions[:playstyle_tags].include? tag 
          champion.playstyle_tags << tag
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
