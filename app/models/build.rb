class Build < ActiveRecord::Base
  belongs_to :item
  belongs_to :champion 
end
