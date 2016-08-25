task :analytics_test => :environment do
  match = Match.first
  items = Item.all
  championbases = Championbase.all
  champions = match.champions
  current_champion = champions[0]

  def get_top_frequencies(frequencies, threshold = 3)
    frequencies.sort_by(&:last).last(threshold).to_h
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

  Analytics.new_entry("champion_roles", balanced_champion_role_assignments)

  # ap $analytics.get("test")
  # ap $analytics

  # ap $redis.keys("*")
  # ap assign_tags_within_treshold(10, stat_averages, stat_value_congregation)

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
      if top_tag_frequencies.key? otag
        top_tag_frequencies[otag] += 1
      elsif !top_tag_frequencies.key? otag
        top_tag_frequencies[otag] = 1
      end
    end

    c_base.playstyle_tags.each do |otag|
      if top_tag_frequencies.key? otag
        top_tag_frequencies[otag] += 1
      elsif !top_tag_frequencies.key? otag
        top_tag_frequencies[otag] = 1
      end
    end    
  end

  bottom_tag_frequencies = {}
  teams[:bottom].each do |champion|
    c_base = champion.championbase

    c_base.build_tags.each do |otag|
      if bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] += 1
      elsif !bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] = 1
      end
    end

    c_base.playstyle_tags.each do |otag|
      if bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] += 1
      elsif !bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] = 1
      end
    end    
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

  p get_top_frequencies(top_tag_frequencies)
  p get_top_frequencies(bottom_tag_frequencies)

  p top_tag_frequencies
  p bottom_tag_frequencies

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

  # top_average_winrates = top_winrates.inject{ |sum, el| p sum + el }

  # Complete!
  p top_average_winrates
  p bottom_average_winrates

  p top_average_scores
  p bottom_average_scores

end