class Reference < ActiveRecord::Base
  belongs_to :node
  belongs_to :neighbour, class_name: 'Node'
end
