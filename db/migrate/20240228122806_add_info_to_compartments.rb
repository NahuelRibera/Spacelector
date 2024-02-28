class AddInfoToCompartments < ActiveRecord::Migration[7.1]
  def change
    add_column :compartments, :info, :text
  end
end
