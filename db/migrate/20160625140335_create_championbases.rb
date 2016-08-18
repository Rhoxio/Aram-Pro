class CreateChampionbases < ActiveRecord::Migration
  def change
    create_table :championbases do |t|

      t.string :name
      t.string :title
      t.string :champion_identifier

      t.string :blurb
      t.string :image

      t.float :score
      t.float :win_rate
      t.float :pick_rate
      t.float :KDA

      t.string :tier

      t.integer :rating, default: 0

      t.string :riot_tags, array: true
      t.string :build_tags, array: true, default: []
      t.string :playstyle_tags, array: true, default: []

      t.text :stats

      t.timestamps null: false
    end
  end
end