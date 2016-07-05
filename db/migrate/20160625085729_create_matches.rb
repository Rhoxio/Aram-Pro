class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|

      t.string :match_id, uniqueness: true, null: false
      t.string :platform_id
      t.string :user_id

      t.timestamps null: false
    end
  end
end
