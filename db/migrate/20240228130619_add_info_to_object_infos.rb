class AddInfoToObjectInfos < ActiveRecord::Migration[7.1]
  def change
    add_column :object_infos, :info, :text
  end
end
