class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.belongs_to :item, index: true
      t.belongs_to :champion, index: true
      t.belongs_to :championbase, index: true

      t.timestamps null: false
    end
  end
end
