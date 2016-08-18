class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_identifier
      t.string :name
      t.string :image
      t.string :description
      t.string :short_description

      t.string :group
      t.string :tags, array: true
      t.boolean :aram_item, default: false
      t.integer :build_depth

      t.string :good_against, array: true
      t.string :good_on, array: true
      t.string :good_at, array: true

      t.text :gold
      t.text :stats
      t.text :effect

      t.timestamps null: false
    end
  end
end
