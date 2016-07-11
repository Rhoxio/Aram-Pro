class Champion < ActiveRecord::Base
  belongs_to :match
  belongs_to :championbase
  belongs_to :item

  accepts_nested_attributes_for :championbase
end
