class Node < ActiveRecord::Base
  belongs_to :user
  has_many :references
  has_many :neighbours, through: :references, class_name: 'Node'
  validates_presence_of :title
  validates_presence_of :content

  def refs_from_source
    content
    .scan(/\[([^\]]+)\]: *<?([^\s>]+)>?(?: +[(]([^\n]+)[)])? *(?:\n+|)/)
    .map { |m| m[1] }
    .select { |href| href[/^\/nodes\//] }
    .map { |href| href[/.*\/(\d+)$/]; $1.to_i }
  end
end
