class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.integer :user_id
      t.string :name
      t.string :category
      t.string :color
      t.string :season
      t.string :image_url
      t.text :notes
      t.text :tags_json
      t.datetime :archived_at

      t.timestamps
    end
  end
end
