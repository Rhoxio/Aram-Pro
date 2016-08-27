task :analytics_test => :environment do
  match = Match.find(4)
  items = Item.all
  championbases = Championbase.all
  champions = match.champions
  current_champion = champions[9]


  def get_top_frequencies(frequencies, threshold = 5)
    frequencies.sort_by(&:last).last(threshold).reverse.to_h.deep_symbolize_keys
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

  item_sym_to_tag_translation = {
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

  item_stat_counters = {
    :movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
    :hitpoints => [:high_dps, :good_scaling, :early_power],
    :critical_chance => [:armor, :hitpoints, :tanky],
    :magic_damage => [:magic_resist, :hitpoints, :tanky],
    :mana => [:poke, :self_healing, :good_scaling, :poke],
    :armor => [:armor_penetration, :true_damage],
    :magic_resist => [:magic_penetration, :true_damage],
    :physical_damage => [:armor, :hitpoints, :tanky],
    :attack_speed => [:armor, :hitpoints, :tanky],
    :lifesteal => [],
    :hp_regen => [:mana, :mana_regen, :high_dps],
    :percent_movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
    :mana_regen => [:poke, :early_power, :good_scaling],
    :armor_penetration => [],
    :magic_penetration => []
  }

  archetype_stat_weights = {
    :tanky => {
      :high => [:hitpoints, :armor, :magic_resist], 
      :medium => [:hp_regen, :movespeed, :percent_movespeed, :physical_damage, :magic_damage], 
      :low => [:physical_damage, :magic_damage, :mana], 
      :irrelevant => [:critical_chance, :attack_speed, :lifesteal]
    },
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
  ap current_champion.name
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

  def top_stat_by_value(frequencies, threshold = 5)
    frequencies.sort_by {|k,v| v[:total_value]}.last(threshold).reverse.to_h
  end 

  def top_stat_by_count(frequencies, threshold = 5)
    frequencies.sort_by {|k,v| v[:count]}.last(threshold).reverse.to_h
  end   

  ap top_stat_by_value(stat_spread)
  ap top_stat_by_count(stat_spread)

  top_tags = get_top_frequencies(top_tag_frequencies)
  bottom_tags = get_top_frequencies(bottom_tag_frequencies)
  ap top_tags
  ap bottom_tags

  tag_sets = [bottom_tags, top_tags]

  # ap top_tag_frequencies
  # ap bottom_tag_frequencies  

  # I now have stat spread and frequencies. Now, I need to check if the frequency itself is
  # enough to merit sticking to the popular build based on the tags present in top_tag_frequencies
  # or bottom_tag_frequencies based upon which team current_champion is on.

  # Unless something is really fucked up with the champion tag spreads, you should have a majority consisting of
  # either :tanky or :squishy_(type) champions with some :hybrid mixed in. The stat weights hash should hold a roadmap to help guide wether or not
  # an item with specific stats would be an acceptable choice for a substitution in the build.

  # Grabbing the primary tag that is most prevalent in the top 5 tags for the opposing team.
  # Will always give back one.
  def extract_primary_tag(current_champion, tag_sets)
    # 0 bottom, 1 top
    if current_champion.team == "100"
      tag_sets[0].each do |tag, value|
        if [:squishy_support, :squishy_physical, :squishy_mage, :hybrid, :tanky].include? tag
          ap tag
          return tag
        end
      end
    elsif current_champion.team == "200"
      tag_sets[1].each do |tag, value|
        if [:squishy_support, :squishy_physical, :squishy_mage, :hybrid, :tanky].include? tag
          ap tag
          return tag
        end
      end
    end
    p "No primary tags found."
    return nil
  end

  # Need to find the most prominent tag on the enemy team now...

  # item_stat_counters = {
  #   :movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
  #   :hitpoints => [:high_dps, :good_scaling, :early_power],
  #   :critical_chance => [:armor, :hitpoints, :tanky],
  #   :magic_damage => [:magic_resist, :hitpoints, :tanky],
  #   :mana => [:poke, :self_healing, :good_scaling, :poke],
  #   :armor => [:armor_penetration, :true_damage],
  #   :magic_resist => [:magic_penetration, :true_damage],
  #   :physical_damage => [:armor, :hitpoints, :tanky],
  #   :attack_speed => [:armor, :hitpoints, :tanky],
  #   :lifesteal => [],
  #   :hp_regen => [:mana, :mana_regen, :high_dps],
  #   :percent_movespeed => [:aoe_cc, :heavy_cc, :roots, :slows],
  #   :mana_regen => [:poke, :early_power, :good_scaling]
  # }  

  # :squishy_physical => {
  #   :high =>[:physical_damage, :armor_penetration, :critical_chance, :lifesteal, :attack_speed], 
  #   :medium => [:movespeed, :percent_movespeed], 
  #   :low => [:armor, :magic_resist, :hitpoints],
  #   :irrelevant => [:magic_damage, :hp_regen, :mana_regen, :mana]
  # },  

  primary_tag_archetype = archetype_stat_weights[extract_primary_tag(current_champion, tag_sets)]

  # Gived back the 
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



  # primary_tags.each do |prime_tag|
  #   case prime_tag
  #   when :squishy_physical
  #     weights = archetype_stat_weights[:squishy_physical]
  #     high_value = weights[:high].map {|tag| item_sym_to_tag_translation[tag]}

   

  # end  

  # ap weights = archetype_stat_weights[:squishy_physical]
  # ap high_value = weights[:high].map {|tag| item_sym_to_tag_translation[tag]}


  # Complete!
  # p top_average_winrates
  # p bottom_average_winrates

  # p top_average_scores
  # p bottom_average_scores




end