task :analytics_test => :environment do
  match = Match.first
  champions = match.champions
  current_champion = champions[0]

  def get_top_frequencies(frequencies, threshold = 3)
    frequencies.sort_by(&:last).last(threshold).to_h
  end  

  teams = {
    :top => [],
    :bottom => []
  }

  # Sort Teams Out
  champions.each do |champion|
    if champion.team == '100'
      teams[:bottom].push(champion)
    else
      teams[:top].push(champion)
    end
  end

  # Frequencies of tags for the given match.
  top_tag_frequencies = {}
  teams[:top].each do |champion|
    c_base = champion.championbase

    c_base.other_tags.each do |otag|
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

    c_base.other_tags.each do |otag|
      if bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] += 1
      elsif !bottom_tag_frequencies.key? otag
        bottom_tag_frequencies[otag] = 1
      end
    end
  end

  # p get_top_frequencies(top_tag_frequencies)
  # p get_top_frequencies(bottom_tag_frequencies)

  # p top_tag_frequencies
  # p bottom_tag_frequencies

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
  # p top_average_winrates
  # p bottom_average_winrates

  # p top_average_scores
  # p bottom_average_scores

end