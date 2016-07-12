class Rune < ActiveRecord::Base
  serialize :stats

  validates :rune_identifier, uniqueness: true

  def self.seed_rune_list
    request = "https://global.api.pvp.net/api/lol/static-data/na/v1.2/rune?locale=en_US&version=6.14.1&runeListData=all&api_key=#{ENV['RIOT_KEY']}"
    response = HTTParty.get(request)
    runes = response.parsed_response

    runes['data'].each do |key, data|
      rune = Rune.new

      rune.rune_identifier = key
      rune.name = data["name"]
      rune.description = data['description']
      rune.image = "http://ddragon.leagueoflegends.com/cdn/6.14.1/img/rune/#{key}.png"
      rune.rune_type = data['rune']['type']
      rune.tier = data['rune']['tier'].to_i

      rune.stats = data['stats']
      rune.tags = data['tags']

      if rune.save
        puts "#{rune.name} was saved!"
      else
        puts 'Rune did not save'
      end
    end
  end
end
