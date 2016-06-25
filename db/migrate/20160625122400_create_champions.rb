class CreateChampions < ActiveRecord::Migration
  def change
    create_table :champions do |t|

    	t.string :champion_id

    	t.string :runes, array: true
    	t.string :masteries, array: true
    	t.string :summoner_spells, array: true

    	t.string :summoner_id
    	t.string :team

    	t.belongs_to :match, index: true

      t.timestamps null: false
    end
  end
end