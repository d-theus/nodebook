class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.integer :node_id
      t.integer :neighbour_id

      t.timestamps
    end
  end
end
