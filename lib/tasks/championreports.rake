task :export_champ_tiers => :environment do

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
    # f.puts "contents"
    sorted_champs.each do |tier, champions|
      f.puts "# #{tier.to_s.upcase}"
      champions.each do |champ|
        f.puts "### #{champ.name}"
        f.puts "<img src='http://ddragon.leagueoflegends.com/cdn/6.16.2/img/champion/#{champ.image}' width='48'>"
      end
    end

  end

end