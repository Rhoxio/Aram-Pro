class Item < ActiveRecord::Base
  has_many :builds
  has_many :champions, through: :builds

  validates :item_identifier, uniqueness: true

  serialize :gold
  serialize :stats
  serialize :effect

  def self.seed_item_list
    # The goal of this method is to create and seed the database with items from the
    # RiotAPI item static data endpoint. Most nested attributes including gold cost are going to be
    # serialized and just saved as a hash.

    # .gsub("<[^>]*>", ""); A regex to strip tags out from the description if need be.

    request = "http://ddragon.leagueoflegends.com/cdn/6.12.1/data/en_US/item.json"
    response = HTTParty.get(request)
    items = response.parsed_response

    # puts JSON.pretty_generate(items)

    items["data"].each do |key, data|
      item = Item.new
      item.item_identifier = key
      item.name = data['name']
      item.image = "http://ddragon.leagueoflegends.com/cdn/6.14.1/img/item/#{key}.png"
      item.description = data['description']
      item.short_description = data['plaintext']

      item.group = data['group']
      item.tags = data['tags']
      item.aram_item = data['maps']['12'] == true || false
      item.build_depth = data['depth'].to_i

      item.gold = data['gold']
      item.stats = data['stats']
      item.effect = data['effect']

      if item.save
        puts "#{item.name} was saved!"
      else
        puts 'Item was not saved.'
      end
    end
  end
end
