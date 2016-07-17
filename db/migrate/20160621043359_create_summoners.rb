class CreateSummoners < ActiveRecord::Migration
  def change
    create_table :summoners do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.integer :level
      t.string :summoner_identifier
      t.integer :icon_id

      t.timestamps null: false
    end
  end
end
