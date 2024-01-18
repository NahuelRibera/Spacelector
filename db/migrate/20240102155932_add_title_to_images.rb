class AddTitleToImages < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :title, :string
  end
end
