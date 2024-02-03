class AddParentSpaceIdToSpaces < ActiveRecord::Migration[7.1]
  def change
    add_column :spaces, :parent_space_id, :bigint
  end
end
