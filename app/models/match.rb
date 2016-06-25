class Match < ActiveRecord::Base
 validates_uniqueness_of :match_id

 has_many :champions
end
