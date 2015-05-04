class AddCoordsToNodes < ActiveRecord::Migration
  def change
    add_column :nodes, :x, :integer
    add_column :nodes, :y, :integer
  end
end
