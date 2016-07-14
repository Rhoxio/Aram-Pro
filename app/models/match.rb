require 'date'

class Match < ActiveRecord::Base
  validates_uniqueness_of :match_id
  belongs_to :user

  has_many :champions

  def process_champions
  end

  def build_from_current_match(match, current_user)
    #This is a creative method. It will save a new model and return the result.

    match = Match.new()

    match.match_id = match['gameId']
    match.platform_id = match['platformId']
    match.user = current_user
    match.match_created_at = DateTime.strptime(match['gameStartTime'].to_s,'%s') 
    match.completed = false

    match['participants'].each do |participant|
      spell_1 = participant['spell1Id']
      spell_2 = participant['spell2Id']

      base = Championbase.find_by(champion_identifier: participant['championId'])

      match['participants'].each do |participant|
        new_match.champions << Champion.build_champion(participant)
      end

      if match.save
        puts "Match was built and saved!"
        return match
      else
        puts "Match attempted to be built and already existed."
        return {status: 'No match created.'}
      end
    end 
  end

  def self.build_from_recent_matches(matches, current_user)

    p 'Building matches...'

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
        puts '-- New Match --'
        ap new_match.champions[0]
      end 
    end

    if all_matches.length > 1
      return all_matches
    else
      return {status: 'No matches created.'}
    end
  end

end
