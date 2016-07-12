class CreateRunes < ActiveRecord::Migration
  def change
    create_table :runes do |t|
      t.string :rune_identifier
      t.string :name
      t.string :description
      t.string :image

      t.string :rune_type
      t.integer :tier
      
      t.text :stats

      t.string :tags, array: true

      t.timestamps null: false
    end
  end
end
