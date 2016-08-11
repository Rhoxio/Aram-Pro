class CreateMatchups < ActiveRecord::Migration
  def change
    create_table :matchups do |t|

      # TAG FREQUENCY
      # most_common_blue_tag : Whatever tag was dominant in the match for blue team
      # most_common_purple_tag : Whatever tag was dominant in the match for purple team

      # MATCHUP BIAS AND ACTUAL
      # team_matchup_bias : Whatever team is projected to win.
      # team_matchup_actual : Whatever team actually ended up winning.

      t.timestamps null: false
    end
  end
end
