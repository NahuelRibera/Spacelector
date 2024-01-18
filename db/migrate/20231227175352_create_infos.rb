class CreateInfos < ActiveRecord::Migration[7.1]
  def change
    create_table :infos do |t|
      t.text :content
      t.references :box, null: false, foreign_key: true

      t.timestamps
    end
  end
end
