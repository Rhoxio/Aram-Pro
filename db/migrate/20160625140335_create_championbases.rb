class CreateChampionbases < ActiveRecord::Migration
  def change
    create_table :championbases do |t|

    	t.string :name
    	t.string :title
    	t.string :champion_identifier

    	t.string :blurb
    	t.string :image
    	t.string :riot_tags, array: true

      t.integer :rating, default: 0

      # Other tags will be used for other forms of classification later.
    	t.string :other_tags, array: true, default: []

    	t.text :stats

      t.timestamps null: false
    end
  end
end

# Example JSON Object...
# Zyra
# {"version"=>"6.12.1", "id"=>"Zyra", "key"=>"143", 
# 	"name"=>"Zyra", "title"=>"Rise of the Thorns", 
# 	"blurb"=>"Longing to take control of her fate, the ancient, dying plant Zyra transferred her consciousness into a human body for a second chance at life. Centuries ago, she and her kind dominated the Kumungu Jungle, using thorns and vines to consume any animal ...", 
# 	"info"=>{"attack"=>4, "defense"=>3, "magic"=>8, "difficulty"=>7}, 
# 	"image"=>{"full"=>"Zyra.png", "sprite"=>"champion4.png", 
# 		"group"=>"champion", "x"=>0, "y"=>48, "w"=>48, "h"=>48}, 
# 		"tags"=>["Mage", "Support"], 
#     "partype"=>"MP", 
#     "stats"=>{
#        "hp"=>499.32, 
# 			 "hpperlevel"=>74.0, "mp"=>334.0, "mpperlevel"=>50.0, 
# 			 "movespeed"=>340.0,
# 			 "armor"=>20.04, 
# 			 "armorperlevel"=>3.0, 
# 			 "spellblock"=>30.0, 
# 			 "spellblockperlevel"=>0.0, 
# 			 "attackrange"=>575.0, "hpregen"=>5.69, 
# 			 "hpregenperlevel"=>0.5, "mpregen"=>8.5, 
# 			 "mpregenperlevel"=>0.8, "crit"=>0.0, 
# 			 "critperlevel"=>0.0, "attackdamage"=>53.376, 
# 			 "attackdamageperlevel"=>3.2, "attackspeedoffset"=>0.0, 
# 			 "attackspeedperlevel"=>2.11}
#  }
# 