class CreateBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :boxes do |t|
      t.integer :top
      t.integer :left
      t.integer :width
      t.integer :height
      t.references :image, foreign_key: true

      t.timestamps
    end
  end
end
