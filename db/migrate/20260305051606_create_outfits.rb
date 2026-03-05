class CreateOutfits < ActiveRecord::Migration[8.0]
  def change
    create_table :outfits do |t|
      t.integer :user_id
      t.string :name
      t.string :occasion
      t.string :season
      t.text :notes
      t.datetime :archived_at
      t.integer :style_id

      t.timestamps
    end
  end
end
