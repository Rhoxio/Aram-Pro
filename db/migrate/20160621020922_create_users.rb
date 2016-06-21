class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      
      t.string :summoner
      t.integer :summoner_id
      t.string :summoner_icon

      t.timestamps null: false
    end
  end
end
