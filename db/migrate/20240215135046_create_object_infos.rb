class CreateObjectInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :object_infos do |t|
      t.references :compartment, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.integer :quantity

      t.timestamps
    end
  end
end
