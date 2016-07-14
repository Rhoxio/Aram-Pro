class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|

      t.string :match_id, uniqueness: true, null: false
      t.string :platform_id
      t.string :user_id

      t.datetime :match_created_at

      t.boolean :completed

      t.timestamps null: false
    end
  end
end
