task :analytics_test => :environment do
  match = Match.find(2)
  items = Item.all
  championbases = Championbase.all
  champions = match.champions
  current_champion = champions[5]

  # This is pseudocode for when I set up tags. 

  # These will be extrapolated out in to helpers.
  def get_top_frequencies(frequencies, threshold = 5)
    frequencies.sort_by(&:last).last(threshold).reverse.to_h.deep_symbolize_keys
  end

  def top_stat_by_value(frequencies, threshold = 5)
    frequencies.sort_by {|k,v| v[:total_value]}.last(threshold).reverse.to_h
  end 

  def top_stat_by_count(frequencies, threshold = 5)
    frequencies.sort_by {|k,v| v[:count]}.last(threshold).reverse.to_h
  end   

  teams = {
    :top => [],
    :bottom => []
  }

  item_stat_translation = {
    "FlatMovementSpeedMod" => :movespeed,
    "FlatHPPoolMod" => :hitpoints,
    "FlatCritChanceMod" => :critical_chance,
    "FlatMagicDamageMod" => :magic_damage,
    "FlatMPPoolMod" => :mana,
    "FlatArmorMod" => :armor,
    "FlatSpellBlockMod" => :magic_resist,
    "FlatPhysicalDamageMod" => :physical_damage,
    "PercentAttackSpeedMod" => :attack_speed,
    "PercentLifeStealMod" => :lifesteal,
    "FlatHPRegenMod" => :hp_regen,
    "PercentMovementSpeedMod" => :percent_movespeed,
    "FlatMPRegenMod" => :mana_regen  
  }

  symbol_to_tag_translation = {
    :movespeed => "FlatMovementSpeedMod",
    :hitpoints => "FlatHPPoolMod",
    :critical_chance => "FlatCritChanceMod",
    :magic_damage => "FlatMagicDamageMod",
    :mana => "FlatMPPoolMod",
    :armor => "FlatArmorMod",
    :magic_resist => "FlatSpellBlockMod",
    :physical_damage => "FlatPhysicalDamageMod",
    :attack_speed => "PercentAttackSpeedMod",
    :lifesteal => "PercentLifeStealMod",
    :hp_regen => "FlatHPRegenMod" ,
    :percent_movespeed => "PercentMovementSpeedMod",
    :mana_regen => "FlatMPRegenMod",
    :armor_penetration => "ArmorPenetration",
    :magic_penetration => "MagicPenetration"
  }  

  popular_stat_counts = Hash.new
  championbases.each do |champion|
    # Make sure the champion's hash exists...
    popular_stat_counts[champion.name] = Hash.new
    champion.popular_items.each do |item|
      item.stats.each do |stat, value|
        # If the stat exists in the champion's specific stat hash... 
        if popular_stat_counts[champion.name].key? item_stat_translation[stat]
          popular_stat_counts[champion.name][item_stat_translation[stat]] += value
        # If it doesn't exist, create and set it.
        elsif !popular_stat_counts[champion.name].key? item_stat_translation[stat]
          popular_stat_counts[champion.name][item_stat_translation[stat]] = value
        end
        # Round it off for easy maths later.
        popular_stat_counts[champion.name][item_stat_translation[stat]] = popular_stat_counts[champion.name][item_stat_translation[stat]].round(2)
      end
    end
  end

  stat_value_congregation = {
    :movespeed => [],
    :hitpoints => [],
    :critical_chance => [],
    :magic_damage => [],
    :mana => [],
    :armor => [],
    :magic_resist => [],
    :physical_damage => [],
    :attack_speed => [],
    :lifesteal => [],
    :hp_regen => [],
    :percent_movespeed => [],
    :mana_regen => []
  }

  # Extracting for averages...
  popular_stat_counts.each do |champion, stats|
    stats.each do |stat|
      stat_value_congregation[stat[0]].push(stat[1])
    end
  end

  # Calculate averages...
  stat_averages = Hash.new
  stat_value_congregation.each do |stat, values|
    stat_averages[stat] = (values.inject{ |sum, el| sum + el }.to_f / values.size).round(2)
    if stat_averages[stat].nan?
       stat_averages[stat] = 0
    end
  end

  # Now, to assign average stat tags to champions dynamically.
  # I may need to implement some sort of treshold that adds 10-15% of the original value to the
  # values in stat_averages to get a more specialized spread of stats to be assigned. I will
  # have to tweek it to see if I can get more balanced outputs, because there is simply no offset right now.

  balanced_champion_role_assignments = Hash.new
  popular_stat_counts.each do |champion, stats|
    balanced_champion_role_assignments[champion] = []
    stats.each do |stat|
      # If the stat is greater than the average...
      if stat[1] > stat_averages[stat[0]] || stat[1] == stat_averages[stat[0]]
        balanced_champion_role_assignments[champion].push(stat[0])
      elsif !(stat[1] > stat_averages[stat[0]])
        # Do nothing for the moment.
      end
    end

    # Adding some tags to balance pure damage/hp variants out.
    if balanced_champion_role_assignments[champion].length <= 1
      if balanced_champion_role_assignments[champion][0] == :physical_damage
        balanced_champion_role_assignments[champion].push(:armor_penetration)
      elsif balanced_champion_role_assignments[champion][0] == :magic_damage
        balanced_champion_role_assignments[champion].push(:magic_penetration)
      elsif balanced_champion_role_assignments[champion][0] == :hitpoints
        balanced_champion_role_assignments[champion].push(:armor)
        balanced_champion_role_assignments[champion].push(:magic_resist)
      end
    end
  end

  # Analytics.new_entry("champion_roles", balanced_champion_role_assignments)

  # ap $analytics.get("test")
  # ap $analytics

  # ap $redis.keys("*")

  # # Sort Teams Out
  champions.each do |champion|
    if champion.team == '100'
      teams[:bottom].push(champion)
    else
      teams[:top].push(champion)
    end
  end

  # # Frequencies of tags for the given match.
  top_tag_frequencies = {}
  teams[:top].each do |champion|
    c_base = champion.championbase

    c_base.build_tags.each do |otag|
      otag_sym = otag.to_sym
      if top_tag_frequencies.key? otag_sym
        top_tag_frequencies[otag_sym] += 1
      elsif !top_tag_frequencies.key? otag_sym
        top_tag_frequencies[otag_sym] = 1
      end
    end

    # c_base.playstyle_tags.each do |otag|
    #   otag_sym = otag.to_sym
    #   if top_tag_frequencies.key? otag_sym
    #     top_tag_frequencies[otag_sym] += 1
    #   elsif !top_tag_frequencies.key? otag_sym
    #     top_tag_frequencies[otag_sym] = 1
    #   end
    # end    
  end

  bottom_tag_frequencies = {}
  teams[:bottom].each do |champion|
    c_base = champion.championbase

    c_base.build_tags.each do |otag|
      otag_sym = otag.to_sym
      if bottom_tag_frequencies.key? otag_sym
        bottom_tag_frequencies[otag_sym] += 1
      elsif !bottom_tag_frequencies.key? otag_sym
        bottom_tag_frequencies[otag_sym] = 1
      end
    end

    # c_base.playstyle_tags.each do |otag|
    #   otag_sym = otag.to_sym
    #   if bottom_tag_frequencies.key? otag_sym
    #     bottom_tag_frequencies[otag_sym] += 1
    #   elsif !bottom_tag_frequencies.key? otag_sym
    #     bottom_tag_frequencies[otag_sym] = 1
    #   end
    # end    
  end

  all_item_tags = Array.new

  items.each do |item|
    if item.aram_item
      item.tags.each do |tag|
        if !all_item_tags.include? tag
          all_item_tags.push(tag)
        end
      end
    end
  end

  all_item_stats = Array.new
  items.each do |item|
    if item.aram_item
      item.stats.each do |key, value|
        if !all_item_stats.include? key
          all_item_stats.push(key)
        end
      end
    end
  end

  # Winrate Arrays
  top_winrates = teams[:top].map{|champ| champ.championbase.win_rate}
  bottom_winrates = teams[:bottom].map{|champ| champ.championbase.win_rate}

  # Top Scores Arrays
  top_scores = teams[:top].map{|champ| champ.championbase.score}
  bottom_scores = teams[:bottom].map{|champ| champ.championbase.score}

  # Averaging Scores
  top_average_scores = (top_scores.inject{ |sum, el| sum + el }.to_f / top_scores.size).round(2)
  bottom_average_scores = (bottom_scores.inject{ |sum, el| sum + el }.to_f / bottom_scores.size).round(2)

  # Averaging Winrates
  top_average_winrates = (top_winrates.inject{ |sum, el| sum + el }.to_f / top_winrates.size).round(2)
  bottom_average_winrates = (bottom_winrates.inject{ |sum, el| sum + el }.to_f / bottom_winrates.size).round(2)

  # I need to compare item tag frequencies for every recommended item on the championbase model against
  # the top tag frequencies. It looks as if I will need to make a table that holds counters to other
  # item archetypes. That comes first:

  # I need to re-think these tags as I am getting non-optimal results. I think
  # That I need to consider either tiering this structure or simply including more
  # precise variance in it. For example: generally investing in magic_damage and magic_penetration will reduce
  # the amount of hitpoints and general defense you have in your build, making you more
  # vulnerable to burst and high dps.

  # I think tiering it will fix the problem and produce better results, but will increase the runtime. 
  # While this doesn't matter, since these calculations will be run once and only once, I may find that it takes
  # much more memory depending on how I implement it and will end up bogging down the Heroku server.

  # Considering adding a zone tag:
  # To me, it would make sense to quantify a team with good poke and good cc abilities as a
  # 'zoning' team that is very good at keeping the other team from ititiating. This might be well-
  # quantified by tagging a champion with a 'kite' tag, becaue while someone with great initiation
  # will help against them, a team without great initiation will struggle and may need to build
  # to compensate for their lack of hard engage.

  item_stat_counters = {
    :movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
    :hitpoints => [:high_dps, :good_scaling, :armor_penetration, :magic_penetration],
    :critical_chance => [:armor, :hitpoints],
    :magic_damage => [:magic_resist, :hitpoints],
    :mana => [:poke, :self_healing, :good_scaling],
    :armor => [:armor_penetration, :true_damage],
    :magic_resist => [:magic_penetration, :true_damage],
    :physical_damage => [:armor, :hitpoints],
    :attack_speed => [:armor, :hitpoints],
    :lifesteal => [:poke], # Reflected damage? 
    :hp_regen => [:mana, :mana_regen, :high_dps, :poke],
    :percent_movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
    :mana_regen => [:poke, :early_power, :good_scaling],
    :armor_penetration => [:health, :armor],
    :magic_penetration => [:health, :magic_resist]
  }

  # Going to eventually turn this in to a model once I get the structure and weights figured out.
  archetype_stat_weights = {
    :tank => {
      :high => [:hitpoints, :armor, :magic_resist], 
      :medium => [:hp_regen, :movespeed, :percent_movespeed, :physical_damage, :magic_damage], 
      :low => [:physical_damage, :magic_damage, :mana], 
      :irrelevant => [:critical_chance, :attack_speed, :lifesteal]
    },

    # Bruisers
    :physical_bruiser => {
      :high => [:hitpoints, :physical_damage, :armor, :magic_resist],
      :mediusm => [:hp_regen, :movespeed, :percent_movespeed, :armor_penetration],
      :low => [:attack_speed, :lifesteal, :mana, :critical_chance],
      :irrelevant => [:magic_damage, :mana_regen, :magic_penetration]
    },
    :magic_bruiser => {
      :high => [:hitpoints, :magic_damage, :armor, :magic_resist],
      :medium => [:movespeed, :percent_movespeed, :magic_penetration],
      :low => [:mana, :mana_regen],
      :irrelevant => [:critical_chance, :physical_damage, :attack_speed, :lifesteal, :hp_regen, :armor_penetration]
    },

    # Squishies
    :squishy_mage => {
      :high => [:magic_damage, :magic_penetration], 
      :medium => [:mana, :mana_regen, :hitpoints], 
      :low => [:armor, :magic_resist, :movespeed, :percent_movespeed], 
      :irrelevant => [:critical_chance, :physical_damage, :attack_speed, :lifesteal, :hp_regen]
    },
    :squishy_physical => {
      :high =>[:physical_damage, :armor_penetration, :critical_chance, :lifesteal, :attack_speed], 
      :medium => [:movespeed, :percent_movespeed], 
      :low => [:armor, :magic_resist, :hitpoints],
      :irrelevant => [:magic_damage, :hp_regen, :mana_regen, :mana]
    },
    :squishy_support => {
      :high =>[:mana_regen, :hitpoints, :magic_damage, :mana], 
      :medium => [:armor, :magic_resist], 
      :low => [:hp_regen, :movespeed, :percent_movespeed],
      :irrelevant => [:critical_chance, :physical_damage, :attack_speed, :lifesteal]
    },

    # Beefy Variants (HP is Strong)
    :beefy_mage => {
      :high => [:hitpoints, :magic_penetration, :magic_damage],
      :medium => [:mana, :mana_regen, :armor, :magic_resist, :movespeed],
      :low => [:mana_regen, :percent_movespeed],
      :irrelevant => [:armor_penetration, :physical_damage, :attack_speed, :lifesteal, :hp_regen, :critical_chance]
    },

    # Hybrid
    :squishy_hybrid => {
      :high => [],
      :medium => [],
      :low => [],
      :irrelevant => []
    },

    :hybrid => {
      :high => [:physical_damage, :magic_damage, :magic_penetration, :armor_penetration, :attack_speed],
      :medium => [:hitpoints, :armor, :magic_resist, :movespeed, :percent_movespeed],
      :low => [:lifesteal, :hp_regen, :mana_regen, :critical_chance],
      :irrelevant => []
    }
  }

  # Now, to get the frequencies of tags for a specific champion's items to see how the 'natural'
  # spread looks against counters.
  stat_spread = Hash.new
  
  current_champion.championbase.popular_items.each do |pitem|
    pitem.stats.each do |stat, value|
      if !stat_spread.key? item_stat_translation[stat]
        stat_spread[item_stat_translation[stat]] = {:total_value => 0, :count => 0}
        stat_spread[item_stat_translation[stat]][:total_value] += value
        stat_spread[item_stat_translation[stat]][:count] += 1
      elsif stat_spread.key? item_stat_translation[stat]
        stat_spread[item_stat_translation[stat]][:total_value] += value
        stat_spread[item_stat_translation[stat]][:count] += 1
      end
    end
  end

  top_tags = get_top_frequencies(top_tag_frequencies)
  bottom_tags = get_top_frequencies(bottom_tag_frequencies)

  tag_sets = [bottom_tags, top_tags] 

  # I now have stat spread and frequencies. Now, I need to check if the frequency itself is
  # enough to merit sticking to the popular build based on the tags present in top_tag_frequencies
  # or bottom_tag_frequencies based upon which team current_champion is on.

  # Need to find the most prominent tag on the enemy team now... 

  primary_tag_archetype = archetype_stat_weights[current_champion.primary_tag.to_sym]

  def map_champion_counters(primary_tag_archetype, item_stat_counters, threshold = 3)
    threat_frequencies = {:high => {}, :medium => {}, :low => {}, :irrelevant => {} }

    primary_tag_archetype[:high].each do |t|
      item_stat_counters[t].each do |ic|
        if !threat_frequencies[:high].key? ic
          threat_frequencies[:high][ic] = 0
          threat_frequencies[:high][ic] += 1
        elsif threat_frequencies[:high].key? ic
          threat_frequencies[:high][ic] += 1
        end
      end     
    end

    primary_tag_archetype[:medium].each do |t|
      item_stat_counters[t].each do |ic|
        if !threat_frequencies[:medium].key? ic
          threat_frequencies[:medium][ic] = 0
          threat_frequencies[:medium][ic] += 1
        elsif threat_frequencies[:medium].key? ic
          threat_frequencies[:medium][ic] += 1
        end
      end     
    end

    primary_tag_archetype[:low].each do |t|
      item_stat_counters[t].each do |ic|
        if !threat_frequencies[:low].key? ic
          threat_frequencies[:low][ic] = 0
          threat_frequencies[:low][ic] += 1
        elsif threat_frequencies[:low].key? ic
          threat_frequencies[:low][ic] += 1
        end
      end     
    end

    primary_tag_archetype[:irrelevant].each do |t|
      item_stat_counters[t].each do |ic|
        if !threat_frequencies[:irrelevant].key? ic
          threat_frequencies[:irrelevant][ic] = 0
          threat_frequencies[:irrelevant][ic] += 1
        elsif threat_frequencies[:irrelevant].key? ic
          threat_frequencies[:irrelevant][ic] += 1
        end
      end     
    end              

    threat_frequencies.each do |k, v|
      threat_frequencies[k] = threat_frequencies[k].sort_by {|k,v| v}.last(threshold).reverse.to_h
    end

    return threat_frequencies

  end
  ap current_champion.name
  ap map_champion_counters(primary_tag_archetype, item_stat_counters, 5)

  # ap weights = archetype_stat_weights[:squishy_physical]
  # ap high_value = weights[:high].map {|tag| item_sym_to_tag_translation[tag]}


end