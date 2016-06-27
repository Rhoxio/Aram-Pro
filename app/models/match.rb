class Match < ActiveRecord::Base
	validates_uniqueness_of :match_id
	belongs_to :user

	has_many :champions

 	def process_champions
 		p self.cmapions
 	end

end
