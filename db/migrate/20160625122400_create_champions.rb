class CreateChampions < ActiveRecord::Migration
  # This is the individual champion that is associated with a game.
  # The championbase model is where the immutable data (like base champion stats)
  # live.

  # Some attributes are directly assigned to the model itself, but the entire set of stats gets serialized in
  # postgame_stats in case they need to be accessed later for any reason.
  def change
    create_table :champions do |t|

      t.string :champion_identifier
      t.string :championbase_id
      t.string :summoner_id

      t.string :name
      t.string :summoner_identifier
      t.string :team      

      t.string :masteries, array: true
      t.string :summoner_spells, array: true
      t.string :runes, array: true

      t.string :image

      t.text :postgame_stats
      # postgame_stats holds all of the information below, but the below attributes are defined
      # for convenience and lookup purposes.

      t.boolean :won

      t.integer :gold_earned

      t.integer :damage_dealt_to_champions
      t.integer :total_damage_dealt
      t.integer :damage_taken

      t.integer :kills
      t.integer :deaths
      t.integer :assists
      t.integer :level

      t.integer :healing_done

      t.belongs_to :match, index: true

      t.timestamps null: false
    end
  end
end
