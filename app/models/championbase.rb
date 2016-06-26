class Championbase < ActiveRecord::Base
	serialize :stats

	has_many :champions
end
