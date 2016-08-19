# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# #
# # Examples:
# #
# #   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
# #   Mayor.create(name: 'Emanuel', city: cities.first)

puts "-- Begin Item Seed --"
Item.seed_item_list
puts "-- Begin Rune Seed --"
Rune.seed_rune_list
puts "-- Begin Championbase Seed --"
Championbase.seed_championbase_list
puts "-- Begin Scrape for Champion Stats --"
Championbase.scrape_for_champion_stats
