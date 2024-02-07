class CreateCompartments < ActiveRecord::Migration[7.1]
  def change
    create_table :compartments do |t|
      t.string :name
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height
      t.references :image, null: false, foreign_key: true

      t.timestamps
    end
  end
end
