class Champion < ActiveRecord::Base
  belongs_to :match
  belongs_to :championbase

  accepts_nested_attributes_for :championbase
end
