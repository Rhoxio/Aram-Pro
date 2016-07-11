class Championbase < ActiveRecord::Base
  serialize :stats

  has_many :champions
  validates :champion_identifier, uniqueness: true
end
