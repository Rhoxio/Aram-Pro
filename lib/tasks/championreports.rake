task :export_champ_tiers => :environment do
  aram_items = Item.where(:aram_item => true).sort { |a,b| b.item_identifier.to_i <=> a.item_identifier.to_i }

  champions = Championbase.all
  sorted_champs = {
    :god => [],
    :strong => [],
    :aboveaverage => [],
    :belowaverage => [],
    :weak => [],
    :bad => []
  }

  champions.each do |champ|
    tier = champ.tier.gsub(' ', '').downcase.to_sym

    if sorted_champs.key? tier
      sorted_champs[tier] << champ
    elsif !sorted_champs.key? tier
      sorted_champs[tier] = []
      sorted_champs[tier] << champ
    end
  end

  File.open(File.join(Rails.root, 'champ_tiers.md'), 'w+') do |f|
    sorted_champs.each do |tier, champions|
      # Sort by Winrate
      champions = champions.sort { |a,b| b.win_rate <=> a.win_rate }


      f.puts "<h1> #{tier.to_s.upcase} </h1>"
      champions.each do |champ|         

        f.puts "### #{champ.name}"
        f.puts "<img src='http://ddragon.leagueoflegends.com/cdn/6.16.2/img/champion/#{champ.image}' width='48'>"
        f.puts "##### Score: #{champ.score}"
        f.puts "##### Winrate: #{champ.win_rate}"
        f.puts "###### KDA: #{champ.KDA}"
        f.puts "###### Pick Rate: #{champ.pick_rate}"
        f.puts "###### Riot Tags: " +champ.riot_tags.join(", ").gsub('_', ' ')
        f.puts "###### Build Tags: " +champ.build_tags.join(", ").gsub('_', ' ')
        f.puts "###### Playstyle Tags: " +champ.playstyle_tags.join(", ").gsub('_', ' ')
        f.puts "---"
      end
    end
  end

  File.open(File.join(Rails.root, 'item_tags.md'), 'w+') do |f|
    aram_items.each do |item|     

      f.puts "### #{item.name}"
      f.puts "<img src='#{item.image}' width='48'>"
      f.puts "###### Riot Tags: " +item.tags.join(", ").gsub('_', ' ')
      if item.attributes['good_against'] && item.attributes['good_on'] && item.attributes['good_at']
        f.puts "###### Good Against: " +item.good_against.join(", ").gsub('_', ' ')
        f.puts "###### Good On: " +item.good_on.join(", ").gsub('_', ' ')
        f.puts "###### Good At: " +item.good_at.join(", ").gsub('_', ' ')
      end

      f.puts "---"
    end
  end  

end