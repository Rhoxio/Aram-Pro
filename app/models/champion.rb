class Champion < ActiveRecord::Base
  belongs_to :match
  belongs_to :championbase

  has_many :builds
  has_many :items, through: :builds

  accepts_nested_attributes_for :championbase

  def self.build_champion(participant)
    champion = Champion.new
    spell_1 = participant['spell1Id']
    spell_2 = participant['spell2Id']

    base = Championbase.find_by(champion_identifier: participant['championId'])

    champion.champion_identifier = participant['championId'],
    champion.summoner_identifier = participant['summonerId'], 
    champion.masteries = participant['masteries'],
    champion.runes = participant['runes'],
    champion.summoner_spells = [spell_1, spell_2],
    champion.team = participant['teamId'],
    champion.name = base.name,
    champion.image = "http://ddragon.leagueoflegends.com/cdn/6.12.1/img/champion/#{base.image}",
    champion.championbase = base     

    return champion
  end
end
