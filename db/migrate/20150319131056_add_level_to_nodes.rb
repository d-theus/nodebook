class AddLevelToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :level, :integer, default: 0
  end
end
