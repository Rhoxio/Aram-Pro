class Champion < ActiveRecord::Base
  belongs_to :match
  belongs_to :championbase
  has_many :builds
  has_many :items, through: :builds

  accepts_nested_attributes_for :championbase
end
