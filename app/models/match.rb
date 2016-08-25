require 'date'

class Match < ActiveRecord::Base
  validates_uniqueness_of :match_id

  belongs_to :user
  has_many :champions

  serialize :winrates
  serialize :scores

  def self.build_from_current_match(match, current_user)
    #This is a creative method. It will save a new model and return the result.

    new_match = Match.new()

    new_match.match_id = match['gameId']
    new_match.platform_id = match['platformId']
    new_match.user = current_user
    new_match.match_created_at = match['gameStartTime'] 
    new_match.completed = false   

    match['participants'].each do |participant|
      new_match.champions << Champion.build_champion(participant)
    end   

    if new_match.save
      puts "Match was built and saved!"
      finalized_match = new_match.calculate_team_data
      if !finalized_match.class == Hash
        return finalized_match
      else
        return finalized_match[:error]
      end      
    else
      puts "Match attempted to be built and already existed."
      return {status: 'No match created.'}
    end     
  end

  def self.build_from_recent_matches(matches, current_user)

    # Assigning each participant their summoner ID based on the champion they played.
    # This works due to the fact that there will be no duplicate champions in an ARAM game.
    player_sorted_matches = matches.map do |match|
      match[:players].each do |player|
        match[:match_data]["participants"].each do |participant|
          if participant['championId'] == player['championId']
            participant['summonerId'] = player['summonerId']
          end
        end
      end
      # Return the amended match object.
      match
    end

    # Where all of the matches are going to be pushed to in the loop below...
    all_matches = Array.new

    player_sorted_matches.each do |match|
      # To make this less confusing it should really just be called a match now. No need for the players hash.
      match = match[:match_data]

      # Create a match scaffold and start assigning.
      new_match = Match.new
      new_match.match_id = match['matchId']
      new_match.platform_id = match['platformId']
      new_match.user = current_user
      new_match.match_created_at = DateTime.strptime(match['matchCreation'].to_s,'%s') 
      new_match.completed = true

      match['participants'].each do |participant|
        new_match.champions << Champion.build_champion(participant)
      end

      # If it saves, push it to the array to be returned.
      if new_match.save
        puts "Match was built and saved!"
        all_matches.push(new_match)
      else
        puts "Match attempted to be built and already existed."
      end 
    end

    if all_matches.length > 1
      final_matches = []

      all_matches.each do |match|
        finalized_match = match.calculate_team_data
        if !finalized_match.class == Hash
          final_matches.push(finalized_match)
        else
          return finalized_match[:error]
        end
      end

      return final_matches
    else
      return {status: 'No matches created.'}
    end
  end

  #####################
  # Analytics Reports #
  #####################

  # These methods are going to basically take an already made model and update it by themselves.
  # These might become more popular as I set up more analytics models, and these types of methods will most
  # certainly become more prevalent once I get a production API key and can start polling the Riot API to collect 
  # larger sets of data to run them against.

  def calculate_team_data

    teams = {
      :top => [],
      :bottom => []
    }
    # # Sort Teams Out
    if self.champions.length > 0
      self.champions.each do |champion|
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

      # I'm going to basically save the team data for the model right in this method and have it return a copy of itself.
      data = {winrates: {top: top_average_winrates, bottom: bottom_average_winrates}, scores: {top: top_average_scores, bottom: bottom_average_winrates}}
      self.winrates = data[:winrates]
      self.scores = data[:scores]

      if self.save
       return self 
      else
        return {error: "Problem assigning winrates or scores to match."}
      end

    else
      return {error: "No champions present on Match."}
    end
  end

end
