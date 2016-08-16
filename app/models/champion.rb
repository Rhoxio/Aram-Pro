class Champion < ActiveRecord::Base
  belongs_to :match
  belongs_to :championbase
  belongs_to :summoner

  has_many :builds
  has_many :items, through: :builds
  has_many :projected_builds, through: :builds, source: :item
  
  serialize :postgame_stats

  accepts_nested_attributes_for :championbase

  def self.build_champion(participant)
    champ_id = participant['championId'].to_i
    
    champion = Champion.new
    spell_1 = participant['spell1Id']
    spell_2 = participant['spell2Id']

    base = Championbase.find_by(champion_identifier: participant['championId'])

    champion.champion_identifier = participant['championId']
    champion.summoner_identifier = participant['summonerId']
    champion.masteries = participant['masteries']
    champion.runes = participant['runes']
    champion.summoner_spells = [spell_1, spell_2]
    champion.team = participant['teamId']
    champion.name = base.name
    champion.image = "http://ddragon.leagueoflegends.com/cdn/6.12.1/img/champion/#{base.image}"
    champion.championbase = base

    # If there is a stats hash present from the recent-matches API call...
    if participant.has_key? 'stats'
      stats = participant['stats']

      champion.postgame_stats = stats
      champion.won = stats['winner']
      champion.gold_earned = stats['goldEarned']
      champion.damage_dealt_to_champions = stats['totalDamageDealtToChampions']
      champion.total_damage_dealt = stats['totalDamageDealt']
      champion.damage_taken = stats['totalDamageTaken']
      champion.kills = stats['kills']
      champion.deaths = stats['deaths']
      champion.assists = stats['assists']
      champion.level = stats['champLevel']
      champion.healing_done = stats['totalHeal']

      # Now to assign items to the champion.

      item_ids = []
      inventory_slot = 6
      while inventory_slot >= 0
        item_ids.push(stats['item' + inventory_slot.to_s].to_s)
        inventory_slot -= 1
      end

      item_ids.each do |item|
        if item != '0'
          found_item = Item.find_by(item_identifier: item)
          champion.items << found_item
        end
      end

    end

    return champion
  end
end
