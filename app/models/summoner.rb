class Summoner < ActiveRecord::Base
  belongs_to :user

  validates_uniqueness_of :summoner_identifier

  has_many :champions 

  def self.build_summoner(attributes)
    summoner = Summoner.new()

    summoner.name = attributes['name']
    summoner.level = attributes['summonerLevel']
    summoner.summoner_identifier = attributes['id']
    summoner.icon_id = attributes['profileIconId']

    return summoner
  end
end
