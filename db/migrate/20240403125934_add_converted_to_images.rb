class AddConvertedToImages < ActiveRecord::Migration[7.1]
  def change
    add_column :images, :converted, :boolean
  end
end
